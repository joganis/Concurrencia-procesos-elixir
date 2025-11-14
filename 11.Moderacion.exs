defmodule Moderacion do
  @palabras_prohibidas ["spam", "estafa", "fraude", "porno", "mentira"]
  @regex_link ~r/http|www|\.(com|net|org)/

  def moderar(%Comentario{id: id, texto: texto}) do
    :timer.sleep(Enum.random(5..12))

    resultado =
      cond do
        contiene_prohibidas?(texto) ->
          :rechazado

        contiene_links?(texto) ->
          :rechazado

        String.length(texto) < 5 ->
          :rechazado

        true ->
          :aprobado
      end

    IO.puts("Comentario #{id} → #{resultado}")

    {id, resultado}
  end

  defp contiene_prohibidas?(texto) do
    texto
    |> String.downcase()
    |> String.split()
    |> Enum.any?(&(&1 in @palabras_prohibidas))
  end

  defp contiene_links?(texto) do
    texto =~ @regex_link
  end

  def secuencial(comentarios) do
    Enum.map(comentarios, &moderar/1)
  end

  def concurrente(comentarios) do
    comentarios
    |> Enum.map(fn c -> Task.async(fn -> moderar(c) end) end)
    |> Task.await_many()
  end

  def generar_comentarios(n \\ 10) do
    ejemplos = [
      "Excelente servicio",
      "Muy malo, parece fraude",
      "Lo recomiendo mucho",
      "Visita www.misitio.com",
      "spam spam spam",
      "ok",
      "Gran calidad del producto",
      "Esto es una estafa",
      "Me encantó!",
      "Buen precio"
    ]

    Enum.map(1..n, fn id ->
      %Comentario{id: id, texto: Enum.random(ejemplos)}
    end)
  end

  def iniciar do
    comentarios = generar_comentarios()

    IO.puts("\nMODERACIÓN SECUENCIAL...")
    tiempo_secuencial =
      Benchmark.determinar_tiempo_ejecucion({Moderacion, :secuencial, [comentarios]})

    IO.puts("\nMODERACIÓN CONCURRENTE...")
    tiempo_concurrente =
      Benchmark.determinar_tiempo_ejecucion({Moderacion, :concurrente, [comentarios]})

    IO.puts("\nRESULTADOS")
    IO.puts(Benchmark.generar_mensaje(tiempo_secuencial, tiempo_concurrente))

    IO.puts("\nSimulación completada.\n")
  end
end

Moderacion.iniciar()
