const currentTime = new Date();

const day = new Date();
day.setHours(08, 0o0, 0);
const night = new Date();
night.setHours(18, 0o0, 0);
const body = document.body;

function setMode() {
	if (currentTime <= day || currentTime >= night) {
		body.classList.add('dark-mode');
	} else {
		body.classList.remove('dark-mode');
	}
}
setInterval(function () {
	setMode();
}, 1000 * 60 * 5);

setMode();