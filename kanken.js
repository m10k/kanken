var q = document.getElementById("question");
var c = document.getElementById("comment");
var a = document.getElementById("answer");
var msg = {
	"done": "よしよし、よくできまちた"
};

var questions = undefined;
var question = undefined;

a.addEventListener("keypress",  function(event) {
	if (event.key === "Enter") {
		event.preventDefault();
		handle_answer();
	}
});

function initialize_question_array() {
	questions = [];
	while (questions.length < all_questions.length) {
		var q = Math.floor(Math.random() * all_questions.length);

		if (!questions.includes(q)) {
			questions.push(q);
		}
	}

	console.log("Randomized questions: " + questions);
}

function next_question() {
	if (questions.length == 0) {
		q.innerHTML = msg["done"];
		return;
	}

	question = {};
	question.kanji = all_questions[questions[0]].kanji,
	question.yomi = [];

	for (var i = 0; i < all_questions[questions[0]].yomi.length; i++) {
		question.yomi.push(all_questions[questions[0]].yomi[i]);
	}

	q.innerHTML = "「" + question.kanji + "」の読み方は?";
	c.innerHTML = "";
	c.className = "";
	a.value = "";
}

function start() {
	console.log("Starting game");
	initialize_question_array();
	next_question();
	console.log("question: " + JSON.stringify(question));
}

function handle_answer() {
	if (q.innerHTML == msg["done"]) {
		start();
		return;
	}

	var answer = a.value;
	var answer_idx = question.yomi.indexOf(answer);

	console.log("Answer: " + answer);
	console.log("Correct answers: " + question.yomi);
	console.log("Question: " + question);
	console.log("Answered: " + question.answered);

	if (answer_idx < 0) {
		console.log("Incorrect answer");

		c.innerHTML = "残念";
		c.className = "incorrect";
	} else {
		console.log("Correct answer");

		a.value = "";
		c.innerHTML = "正解";
		c.className = "correct";
		console.log("q: " + JSON.stringify(question));

		/* Remove the answer from the array so it won't be accepted again */
		question.yomi.splice(answer_idx, 1);

		console.log("q: " + JSON.stringify(question));

		if (question.yomi.length > 0) {
			console.log("Some readings have not been answered yet");
			c.innerHTML += "。後は?";
		} else {
			console.log("Answered all readings");
			questions.splice(0, 1);
			next_question();
		}
	}
}

start();
