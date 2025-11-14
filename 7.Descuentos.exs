defmodule Descuentos do


  def total_con_descuentos(%Carrito{id: id, items: items, cupon: cupon}) do
    :timer.sleep(Enum.random(5..15))

    subtotal = Enum.reduce(items, 0, fn item, acc -> acc + item.precio end)

    total =
      subtotal
      |> aplicar_cupon(cupon)
      |> aplicar_descuento_categoria(items)
      |> aplicar_2x1(items)

    IO.puts(" Carrito #{id} procesado → Total: $#{total}")

    {id, total}
  end


  defp aplicar_cupon(total, "DES10"), do: Float.round(total * 0.90, 2)
  defp aplicar_cupon(total, "DES20"), do: Float.round(total * 0.80, 2)
  defp aplicar_cupon(total, _), do: total


  defp aplicar_descuento_categoria(total, items) do
    if Enum.any?(items, &(&1.categoria == :electronica)) do
      Float.round(total * 0.90, 2)
    else
      total
    end
  end

  defp aplicar_2x1(total, items) do
    libros = Enum.filter(items, &(&1.categoria == :libro))

    case length(libros) do
      n when n >= 2 ->
        # Cobra solo la mitad de los libros
        precio_libros = Enum.reduce(libros, 0, fn i, acc -> acc + i.precio end)
        descuento = precio_libros / 2
        Float.round(total - descuento, 2)

      _ ->
        total
    end
  end

  def secuencial(carritos) do
    Enum.map(carritos, &total_con_descuentos/1)
  end


  def concurrente(carritos) do
    carritos
    |> Enum.map(fn c -> Task.async(fn -> total_con_descuentos(c) end) end)
    |> Task.await_many()
  end

  def generar_carritos(n \\ 10) do
    productos = [
      %Item{nombre: "Libro A", precio: 30, categoria: :libro},
      %Item{nombre: "Libro B", precio: 25, categoria: :libro},
      %Item{nombre: "Audífonos", precio: 100, categoria: :electronica},
      %Item{nombre: "Teclado", precio: 80, categoria: :electronica},
      %Item{nombre: "Camiseta", precio: 40, categoria: :ropa},
      %Item{nombre: "Gorra", precio: 20, categoria: :ropa}
    ]

    cupones = ["", "DES10", "DES20"]

    Enum.map(1..n, fn id ->
      %Carrito{
        id: id,
        items: Enum.take_random(productos, Enum.random(2..4)),
        cupon: Enum.random(cupones)
      }
    end)
  end


  def iniciar do
    carritos = generar_carritos()

    IO.puts("\nPROCESAMIENTO SECUENCIAL...")
    tiempo_secuencial =
      Benchmark.determinar_tiempo_ejecucion({Descuentos, :secuencial, [carritos]})

    IO.puts("\nPROCESAMIENTO CONCURRENTE...")
    tiempo_concurrente =
      Benchmark.determinar_tiempo_ejecucion({Descuentos, :concurrente, [carritos]})

    IO.puts("\n RESULTADOS")
    IO.puts(Benchmark.generar_mensaje(tiempo_secuencial, tiempo_concurrente))

    IO.puts("\nSimulación completada.\n")
  end
end

Descuentos.iniciar()
