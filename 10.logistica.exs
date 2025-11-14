defmodule Logistica do

  def preparar(%Paquete{id: id, peso: peso, fragil: fragil}) do
    t_inicio = System.monotonic_time(:millisecond)

    :timer.sleep(Enum.random(20..40))

    :timer.sleep(trunc(peso * 2))

    :timer.sleep(Enum.random(30..60))

    if fragil do
      :timer.sleep(Enum.random(40..70))
    end

    t_fin = System.monotonic_time(:millisecond)
    total = t_fin - t_inicio

    IO.puts("Paquete #{id} listo (frágil: #{fragil}) en #{total} ms")

    {id, total}
  end

  def secuencial(paquetes) do
    Enum.map(paquetes, &preparar/1)
  end

  def concurrente(paquetes) do
    paquetes
    |> Enum.map(fn p -> Task.async(fn -> preparar(p) end) end)
    |> Task.await_many()
  end


  def generar_paquetes(n \\ 10) do
    Enum.map(1..n, fn id ->
      %Paquete{
        id: id,
        peso: Enum.random(1..10),
        fragil: Enum.random([true, false])
      }
    end)
  end

  def iniciar do
    paquetes = generar_paquetes()

    IO.puts("\nPREPARACIÓN SECUENCIAL...")
    tiempo_secuencial =
      Benchmark.determinar_tiempo_ejecucion({Logistica, :secuencial, [paquetes]})

    IO.puts("\nPREPARACIÓN CONCURRENTE...")
    tiempo_concurrente =
      Benchmark.determinar_tiempo_ejecucion({Logistica, :concurrente, [paquetes]})

    IO.puts("\nRESULTADOS")
    IO.puts(Benchmark.generar_mensaje(tiempo_secuencial, tiempo_concurrente))

    IO.puts("\n Simulación completada.\n")
  end
end

Logistica.iniciar()
