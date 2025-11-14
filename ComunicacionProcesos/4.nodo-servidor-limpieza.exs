defmodule Limpieza do
  @stopwords ["el", "la", "los", "las", "de", "y", "un", "una", "en", "es"]

  def limpiar(%Review{id: id, texto: t}) do
    :timer.sleep(Enum.random(5..15))

    resumen =
      t
      |> String.downcase()
      |> quitar_tildes()
      |> quitar_stopwords()

    IO.puts("Servidor: Reseña #{id} limpiada → #{resumen}")
    {id, resumen}
  end

  defp quitar_tildes(texto) do
    texto
    |> String.normalize(:nfd)
    |> String.replace(~r/\p{M}/u, "")
  end

  defp quitar_stopwords(texto) do
    texto
    |> String.split()
    |> Enum.reject(&(&1 in @stopwords))
    |> Enum.join(" ")
  end
end

defmodule NodoServidor do
  @nodo_servidor :"servidor@10.0.67.55"
  @nombre_servicio :servicio_limpieza

  def main() do
    IO.puts("SERVIDOR LIMPIEZA INICIADO")
    iniciar_nodo(@nodo_servidor)
    Process.register(self(), @nombre_servicio)
    loop()
  end

  def iniciar_nodo(nombre) do
    Node.start(nombre)
    Node.set_cookie(:my_cookie)
  end

  defp loop do
    receive do
      {cliente, :fin} ->
        send(cliente, :fin)
        loop()

      {cliente, {:limpiar, %Review{} = r}} ->
        resp = Limpieza.limpiar(r)
        send(cliente, resp)
        loop()

      otro ->
        IO.puts("Servidor → mensaje desconocido: #{inspect(otro)}")
        loop()
    end
  end
end

NodoServidor.main()
