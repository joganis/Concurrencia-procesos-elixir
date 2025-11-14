defmodule Limpieza do
  # Stopwords simples para la demo
  @stopwords ["el", "la", "los", "las", "de", "y", "un", "una", "en", "es"]

  # Función de limpieza
  def limpiar(%Review{id: id, texto: t}) do
    :timer.sleep(Enum.random(5..15))

    resumen =
      t
      |> String.downcase()
      |> quitar_tildes()
      |> quitar_stopwords()
    IO.puts("Reseña #{id} limpiada: #{resumen}")
    {id, resumen}
  end

  # Elimina tildes (versión simple)
  defp quitar_tildes(texto) do
    texto
    |> String.normalize(:nfd)
    |> String.replace(~r/\p{M}/u, "")
  end

  # Elimina stopwords definidos arriba
  defp quitar_stopwords(texto) do
    texto
    |> String.split()
    |> Enum.reject(&(&1 in @stopwords))
    |> Enum.join(" ")
  end

  # Versión secuencial
  def limpiar_secuencial(reviews) do
    Enum.map(reviews, &limpiar/1)
  end

  # Versión concurrente
  def limpiar_concurrente(reviews) do
    reviews
    |> Enum.map(fn r -> Task.async(fn -> limpiar(r) end) end)
    |> Task.await_many()
  end

  # Genera lista de reseñas
  def lista_reviews(n \\ 10) do
    textos = [
      "El producto es excelente y muy útil",
      "La calidad es baja y no lo recomiendo",
      "Un artículo bueno en relación precio y calidad",
      "La entrega fue rápida y el empaque perfecto",
      "Es un producto promedio"
    ]

    Enum.map(1..n, fn i ->
      %Review{id: i, texto: Enum.random(textos)}
    end)
  end

  # Ejecución principal con Benchmark
  def iniciar do
    reviews = lista_reviews()

    IO.puts("\n Limpiando reseñas...")

    t1 = Benchmark.determinar_tiempo_ejecucion({Limpieza, :limpiar_secuencial, [reviews]})
     IO.puts("\n\n\n\n")
    t2 = Benchmark.determinar_tiempo_ejecucion({Limpieza, :limpiar_concurrente, [reviews]})

    IO.puts("\n Resultados de rendimiento:")
    IO.puts(Benchmark.generar_mensaje(t1, t2))

    IO.puts("Tiempo secuencial: #{t1} µs")
    IO.puts("Tiempo concurrente: #{t2} µs")

    IO.puts("\n Speedup calculado: x#{Float.round(Benchmark.calcular_speedup(t1, t2), 2)}")

    IO.puts("\nSimulación completada.\n")
  end
end

Limpieza.iniciar()
