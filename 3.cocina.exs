defmodule Cocina do
  # Simula la preparación de una orden
  def preparar(%Orden{id: id, item: item, prep_ms: tiempo}) do
    :timer.sleep(tiempo)
    IO.puts("✅ Orden #{id}: #{item} lista en #{tiempo} ms.")
    {id, "#{item} (#{tiempo} ms)"}
  end

  # Versión secuencial
  def preparar_secuencial(ordenes) do
    Enum.map(ordenes, &preparar/1)
  end

  # Versión concurrente (un proceso por orden)
  def preparar_concurrente(ordenes) do
    ordenes
    |> Enum.map(fn o -> Task.async(fn -> preparar(o) end) end)
    |> Task.await_many()
  end

  # Genera lista de órdenes
  def lista_ordenes(n \\ 10) do
    items = ["Café", "Latte", "Té", "Sandwich", "Capuccino", "Jugo", "Chocolate", "Croissant"]
    Enum.map(1..n, fn i ->
      %Orden{
        id: i,
        item: Enum.random(items),
        prep_ms: Enum.random(200..800)
      }
    end)
  end

  # Ejecución principal usando Benchmark
  def iniciar do
    ordenes = lista_ordenes()

    IO.puts("\n👨‍🍳 Preparando órdenes...")

    # Medir tiempos usando el módulo Benchmark
    t1 = Benchmark.determinar_tiempo_ejecucion({Cocina, :preparar_secuencial, [ordenes]})
    IO.puts("\n\n\n\n")
    t2 = Benchmark.determinar_tiempo_ejecucion({Cocina, :preparar_concurrente, [ordenes]})

    # Mostrar resultados
    IO.puts("\n📊 Resultados de rendimiento:")
    IO.puts(Benchmark.generar_mensaje(t1, t2))

    IO.puts("Tiempo secuencial: #{t1} µs")
    IO.puts("Tiempo concurrente: #{t2} µs")

    IO.puts("\n⚡ Speedup calculado: x#{Float.round(Benchmark.calcular_speedup(t1, t2), 2)}")

    IO.puts("\nSimulación completada.\n")
  end
end

Cocina.iniciar()
