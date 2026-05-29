extends AnimatedSprite2D

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var area_presenca: Area2D    = $AreaPresenca
@onready var area_hipnose: Area2D     = $AreaHipnose
@onready var timer_canto: Timer       = $TimerCanto
@onready var label_nome: Label        = $LabelNome

enum Ato { NENHUM, ATO1, ATO4 }
var ato_atual: Ato         = Ato.NENHUM
var evento_concluido: bool = false

var piloto: CharacterBody2D = null
var karina: CharacterBody2D = null

signal iara_ato1_iniciado
signal iara_ato4_iniciado
signal piloto_salvo
signal piloto_afogado

func _ready() -> void:
	area_presenca.body_entered.connect(_on_presenca_body_entered)
	area_hipnose.body_entered.connect(_on_hipnose_body_entered)
	timer_canto.timeout.connect(_on_canto_timeout)

	label_nome.text = "Iara"
	label_nome.add_theme_color_override("font_color", Color(0.4, 0.9, 1.0))
	label_nome.position = Vector2(-16, -72)

	sprite.play("idle")

	#Detecta por proximidade
	
func _on_presenca_body_entered(body: Node2D) -> void:
	if evento_concluido:
		return
	if body.is_in_group("player"):
		karina = body
		match ato_atual:
			Ato.ATO1:
				emit_signal("iara_ato1_iniciado")
			Ato.ATO4:
				_iniciar_hipnose_piloto()

# ATO 1 

func iniciar_ato1() -> void:
	ato_atual = Ato.ATO1
	evento_concluido = false
	sprite.play("idle")

func concluir_ato1() -> void:
	evento_concluido = true
	sprite.play("saindo")
	# Ela vai sumir qnd a animação acabar
	await sprite.animation_finished
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.8)
	tween.tween_callback(queue_free)

# ATO 4 - A parte de hipnose

func iniciar_ato4() -> void:
	ato_atual = Ato.ATO4
	evento_concluido = false
	modulate.a = 1.0
	visible = true
	sprite.play("saindo")  # animação de surgir da água
	emit_signal("iara_ato4_iniciado")

func _iniciar_hipnose_piloto() -> void:
	if piloto == null:
		return
	piloto.set_meta("hipnotizado", true)
	timer_canto.start(1.5)

# Canto leve afeta Karina também (se o final não for uma cutscene)
func _on_hipnose_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and ato_atual == Ato.ATO4:
		body.set_meta("hipnotizada", true)
		get_tree().create_timer(2.0).timeout.connect(
			func(): body.set_meta("hipnotizada", false),
			CONNECT_ONE_SHOT
		)

# Verifica se o Piloto chegou na água
func _on_canto_timeout() -> void:
	if piloto == null or evento_concluido:
		return
	# lembrar de ajustar o valor 400.0 para a posição Y da água na versão final do mapa
	if piloto.global_position.y >= 400.0:
		_piloto_afogou()

# Fim do Ato 4

func karina_salvou_piloto() -> void:
	evento_concluido = true
	timer_canto.stop()
	if piloto != null:
		piloto.set_meta("hipnotizado", false)
	if karina != null:
		karina.set_meta("hipnotizada", false)
	emit_signal("piloto_salvo")
	get_tree().create_timer(1.5).timeout.connect(
		func():
			sprite.play("saindo")
			get_tree().create_timer(0.8).timeout.connect(
				func():
					var tween := create_tween()
					tween.tween_property(self, "modulate:a", 0.0, 1.0)
					tween.tween_callback(queue_free),
				CONNECT_ONE_SHOT
			),
		CONNECT_ONE_SHOT
	)

func _piloto_afogou() -> void:
	evento_concluido = true
	timer_canto.stop()
	emit_signal("piloto_afogado")
