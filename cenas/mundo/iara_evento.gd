extends Node

var iara: CharacterBody2D   = null
var karina: CharacterBody2D = null
var piloto: CharacterBody2D = null

signal ato1_concluido
signal ato4_concluido
signal game_over_piloto

func register_refs(p_iara: CharacterBody2D, p_karina: CharacterBody2D, p_piloto: CharacterBody2D = null) -> void:
	iara   = p_iara
	karina = p_karina
	piloto = p_piloto

	iara.karina = karina
	iara.piloto = piloto

	if not iara.iara_ato1_iniciado.is_connected(_on_ato1_iniciado):
		iara.iara_ato1_iniciado.connect(_on_ato1_iniciado)
	if not iara.iara_ato4_iniciado.is_connected(_on_ato4_iniciado):
		iara.iara_ato4_iniciado.connect(_on_ato4_iniciado)
	if not iara.piloto_salvo.is_connected(_on_piloto_salvo):
		iara.piloto_salvo.connect(_on_piloto_salvo)
	if not iara.piloto_afogado.is_connected(_on_piloto_afogado):
		iara.piloto_afogado.connect(_on_piloto_afogado)
	if piloto != null and not piloto.karina_interagiu.is_connected(_on_karina_salvou):
		piloto.karina_interagiu.connect(_on_karina_salvou)

# Ato 1

func iniciar_ato1() -> void:
	if iara == null:
		return
		iara.iniciar_ato1()

func _on_ato1_iniciado(Dialogo) -> void:
		Dialogo.iniciar([
		{
			"nome": "Iara",
			"portrait": "iara",
			"texto": "Ah... visitantes no meu rio. Há muito tempo não via um rosto humano por aqui."
		},
		{
			"nome": "Iara",
			"portrait": "iara",
			"texto": "A seca está castigando, criança. O rio encolheu... a floresta sofre. Os bichos estão com fome e com medo."
		},
		{
			"nome": "Karina",
			"portrait": "karina",
			"texto": "Eu sou enfermeira. Preciso chegar até a comunidade ribeirinha com os suprimentos médicos."
		},
		{
			"nome": "Iara",
			"portrait": "iara",
			"texto": "Eu sei. Sua missão é justa, filha da terra. Vá com cuidado... a floresta guarda segredos perigosos."
		}, ], _on_dialogo_ato1_concluido)

func _on_dialogo_ato1_concluido() -> void:
	iara.concluir_ato1()
	emit_signal("ato1_concluido")

# hipnose do ato 4

func iniciar_ato4() -> void:
	if iara == null:
		return
	iara.iniciar_ato4()

func _on_ato4_iniciado(Dialogo) -> void:
	Dialogo.iniciar([
		{
			"nome": "Iara",
			"portrait": "iara",
			"texto": "Voltou, Karina... mas desta vez não é com você que quero falar."
		},
		{
			"nome": "Iara",
			"portrait": "iara",
			"texto": "Esse piloto... tem algo nele que o rio deseja. Venha, navegante... venha para as profundezas..."
		},
		{
			"nome": "Karina",
			"portrait": "karina",
			"texto": "Não! Piloto, não ouça ela! Fique aqui comigo!"
		},
	], _on_dialogo_ato4_concluido)

func _on_dialogo_ato4_concluido() -> void:
	#hipnose
	pass

func _on_karina_salvou() -> void:
	iara.karina_salvou_piloto()

func _on_piloto_salvo(Dialogo) -> void:
	Dialogo.iniciar([
		{
			"nome": "Karina",
			"portrait": "karina",
			"texto": "Piloto! Está bem? Vamos embora daqui agora!"
		},
		{
			"nome": "Iara",
			"portrait": "iara",
			"texto": "...Você é forte, enfermeira. O rio vai lembrar do seu nome."
		},
	], _on_dialogo_final_concluido)

func _on_dialogo_final_concluido() -> void:
	emit_signal("ato4_concluido")

func _on_piloto_afogado(Dialogo) -> void:
	Dialogo.iniciar([
		{
			"nome": "Iara",
			"portrait": "iara",
			"texto": "O rio levou o que era seu... Você chegou tarde, enfermeira."
		},
	], _on_game_over_dialogo_concluido)

func _on_game_over_dialogo_concluido() -> void:
	emit_signal("game_over_piloto")
