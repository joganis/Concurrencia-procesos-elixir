
defmodule Reportes do

  def generar(%Sucursal{id: id, ventas: ventas}) do
    :timer.sleep(Enum.random(50..120))

    total =
      ventas
      |> Enum.map(& &1)
      |> Enum.sum()

    top3 =
      ventas
      |> Enum.sort(:desc)
      |> Enum.take(3)

    IO.puts("Reporte listo Sucursal #{id}")

    {id, %{total: total, top3: top3}}
  end

  def secuencial(sucursales) do
    Enum.map(sucursales, &generar/1)
  end


  def concurrente(sucursales) do
    sucursales
    |> Enum.map(fn s -> Task.async(fn -> generar(s) end) end)
    |> Task.await_many()
  end


  def lista_sucursales(n \\ 5) do
    Enum.map(1..n, fn i ->
      ventas =
        Enum.map(1..10, fn _ ->
          Enum.random(20..200)   # cantidades de ventas
        end)

      %Sucursal{id: i, ventas: ventas}
    end)
  end

  def iniciar do
    sucursales = lista_sucursales()

    IO.puts("\nREPORTES SECUNCIALES...")
    tiempo_secuencial =
      Benchmark.determinar_tiempo_ejecucion({Reportes, :secuencial, [sucursales]})

    IO.puts("\nREPORTES CONCURRENTE...")
    tiempo_concurrente =
      Benchmark.determinar_tiempo_ejecucion({Reportes, :concurrente, [sucursales]})


    IO.puts("\n RESULTADOS FINALES")
    IO.puts(Benchmark.generar_mensaje(tiempo_secuencial, tiempo_concurrente))

    IO.puts("\nSimulación completada.\n")
  end
end

Reportes.iniciar()
