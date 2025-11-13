defmodule CalculoIVA do

  def precio_final(%Producto{nombre: n, precio_sin_iva: p, iva: i}) do
    total = p * (1 + i)
    :timer.sleep(3)
    {n, Float.round(total, 2)}
  end


  def precios_secuencial(lista) do
    Enum.map(lista, &precio_final/1)
  end

  # Modo concurrente: cada producto en su propio proceso
  def precios_concurrente(lista) do
    lista
    |> Enum.map(fn prod -> Task.async(fn -> precio_final(prod) end) end)
    |> Task.await_many()
  end

  # Genera una lista de productos de ejemplo (puedes aumentar el tamaño)
  def lista_productos(n \\ 500) do
    Enum.map(1..n, fn i ->
      %Producto{
        nombre: "Producto_#{i}",
        stock: :rand.uniform(100),
        precio_sin_iva: :rand.uniform(100) + 10,
        iva: 0.19
      }
    end)
  end

  # Mide el tiempo de ejecución de una función
  def medir_tiempo(fun) do
    {tiempo_us, resultado} = :timer.tc(fun)
    tiempo_ms = tiempo_us / 1000
    {resultado, tiempo_ms}
  end

  # Punto de inicio
  def iniciar do
    productos = lista_productos()

    IO.puts("\nCalculando precios SECUNCIALMENTE...")
    {res1, t1} = medir_tiempo(fn -> precios_secuencial(productos) end)
    IO.puts("Tiempo secuencial: #{Float.round(t1, 2)} ms")

    IO.puts("\nCalculando precios CONCURRENTEMENTE...")
    {res2, t2} = medir_tiempo(fn -> precios_concurrente(productos) end)
    IO.puts("Tiempo concurrente: #{Float.round(t2, 2)} ms")

    speedup = t1 / t2
    IO.puts("\nSpeedup: x#{Float.round(speedup, 2)}")

    # Mostrar los primeros resultados
    IO.puts("\nEjemplo de resultados:")
    Enum.take(res2, 5)
    |> Enum.each(fn {nombre, total} -> IO.puts("  #{nombre} => #{total}") end)

    IO.puts("\nSimulación terminada.\n")
  end
end

CalculoIVA.iniciar()
