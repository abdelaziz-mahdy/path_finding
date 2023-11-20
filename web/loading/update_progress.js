function updateProgress(num) {
  if (num==100){
    const container = document.querySelector('.container');
    container.style.display = 'none';
  }
    const progressBar = document.querySelector('.progress-bar');
    const progressBarText = document.querySelector('.progress-bar__text');
  
    gsap.to(progressBar, {
      x: num + "%",
      duration: 2,
    });
  
    progressBarText.style.display = 'block';
    // progressBarText.textContent = num + "%";
  }