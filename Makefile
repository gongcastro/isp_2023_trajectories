render:
	quarto render docs/index.qmd --to revealjs

deploy:
	git add .
	git commit -m "New version of slides"
	git push

download:
	decktape reveal https://gongcastro.github.io/isp_2023_trajectories C:/Users/gonza/Documents/isp_2023_trajectories/docs/index.pdf

