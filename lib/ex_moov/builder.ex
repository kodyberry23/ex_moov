defmodule ExMoov.Builder do
  defmacro __using__(_) do
    quote do
      import ExMoov.Builder, only: [object: 2, field: 2, field: 3]
      Module.register_attribute(__MODULE__, :objects, accumulate: true)

      @before_compile ExMoov.Builder
    end
  end

  # Macro to define an object with fields
  defmacro object(name, do: block) do
    quote do
      @current_object unquote(name)
      @fields []
      unquote(block)
      @objects {unquote(name), @fields}
    end
  end

  # Macro to define a field within an object
  defmacro field(name, type, opts \\ []) do
    quote do
      # Initialize Ecto.Enum type if specified
      field_type =
        if unquote(type) == Ecto.Enum do
          Ecto.ParameterizedType.init(Ecto.Enum, unquote(opts))
        else
          unquote(type)
        end

      @fields [{unquote(name), field_type} | @fields]
    end
  end

  # Before compile callback to generate the objects map and changeset functions
  defmacro __before_compile__(env) do
    objects = Module.get_attribute(env.module, :objects)

    object_maps =
      Enum.reduce(objects, %{}, fn {name, fields}, acc ->
        Map.put(acc, name, Enum.into(fields, %{}))
      end)

    quote do
      # Function to return the objects map
      def objects do
        unquote(Macro.escape(object_maps))
      end

      # Function to return a specific object with expanded nested objects
      def object(name) do
        objects = unquote(Macro.escape(object_maps))
        expand_object(objects, name)
      end

      # Helper function to expand nested objects
      defp expand_object(objects, name) do
        case Map.get(objects, name) do
          nil ->
            nil

          fields ->
            Enum.reduce(fields, %{}, fn {field_name, field_type}, acc ->
              expanded_type =
                cond do
                  is_atom(field_type) and Map.has_key?(objects, field_type) ->
                    expand_object(objects, field_type)

                  match?({:array, _}, field_type) ->
                    {:array, expand_object(objects, elem(field_type, 1))}

                  true ->
                    field_type
                end

              Map.put(acc, field_name, expanded_type)
            end)
        end
      end

      # Function to generate a changeset for a given object type and parameters
      def map_response(type, params) do
        types = object(type)
        build_changeset(types, params)
      end

      # Helper function to recursively build the changeset for nested objects and arrays
      defp build_changeset(types, params) do
        types =
          Enum.reduce(types, %{}, fn {key, type}, types_acc ->
            cond do
              is_map(type) ->
                nested_changeset = build_changeset(type, Map.get(params, to_string(key), %{}))
                Map.put(types_acc, key, :map)

              match?({:array, {:map, _}}, type) ->
                Map.put(types_acc, key, type)

              # match?({:array, %{}}, type) ->
              #   IO.inspect(Map.put(types_acc, key, {:array, {:map, elem(type, 1)}}))

              match?({:array, _}, type) ->
                Map.put(types_acc, key, type)

              true ->
                Map.put(types_acc, key, type)
            end
          end)

        {%{}, types}
        |> Ecto.Changeset.cast(params, Map.keys(types))
        |> Ecto.Changeset.apply_changes()
      end
    end
  end
end
