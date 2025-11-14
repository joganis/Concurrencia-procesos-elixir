defmodule Backoffice do

  @tareas [:reindex, :purge_cache, :build_sitemap, :sync_stats, :clean_tmp]


  def ejecutar(%Job{id: id, tarea: tarea}) do
    result =
      case tarea do
        :reindex ->
          :timer.sleep(Enum.random(80..120))
          IO.puts("Reindex completado (Job #{id})")
          {:ok, tarea}

        :purge_cache ->
          :timer.sleep(Enum.random(50..80))
          IO.puts("Cache purgada (Job #{id})")
          {:ok, tarea}

        :build_sitemap ->
          :timer.sleep(Enum.random(60..90))
          IO.puts("Sitemap generado (Job #{id})")
          {:ok, tarea}

        :sync_stats ->
          :timer.sleep(Enum.random(40..70))
          IO.puts("Estadísticas sincronizadas (Job #{id})")
          {:ok, tarea}

        :clean_tmp ->
          :timer.sleep(Enum.random(30..50))
          IO.puts("Archivos temporales limpiados (Job #{id})")
          {:ok, tarea}

        _ ->
          IO.puts("Job #{id}: tarea no reconocida")
          {:error, :tarea_no_reconocida}
      end

    {id, result}
  end

  def secuencial(jobs) do
    Enum.map(jobs, &ejecutar/1)
  end

  def concurrente(jobs) do
    jobs
    |> Enum.map(fn j -> Task.async(fn -> ejecutar(j) end) end)
    |> Task.await_many()
  end


  def generar_jobs(n \\ 3) when n >= 1 do
    tareas_escogidas = Enum.take_random(@tareas, Enum.random(3..5))

    Enum.with_index(tareas_escogidas, 1)
    |> Enum.map(fn {tarea, idx} ->
      %Job{id: idx, tarea: tarea}
    end)
  end


  def iniciar do
    jobs = generar_jobs()

    IO.puts("\n JOBS DE BACKOFFICE DEL DÍA:")
    Enum.each(jobs, fn %Job{id: id, tarea: t} -> IO.puts("  Job #{id}: #{t}") end)

    IO.puts("\n EJECUCIÓN SECUENCIAL...")
    tiempo_secuencial =
      Benchmark.determinar_tiempo_ejecucion({Backoffice, :secuencial, [jobs]})

    IO.puts("\n EJECUCIÓN CONCURRENTE...")
    tiempo_concurrente =
      Benchmark.determinar_tiempo_ejecucion({Backoffice, :concurrente, [jobs]})

    IO.puts("\n RESULTADOS")
    IO.puts(Benchmark.generar_mensaje(tiempo_secuencial, tiempo_concurrente))

    IO.puts("\n Backoffice finalizado.\n")
  end
end

Backoffice.iniciar()
