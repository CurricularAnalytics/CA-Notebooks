# CurricularAnalytics.jl Notebooks
This repository serves as a collection of IJulia Notebooks utilizing the CurricularAnalytics.jl Toolbox.

Click the NBViewer link below to preview the notebooks in your browser. Please note that you are not able to run the notebooks, but only view them, if you are using this link. 
**[NBViewer link](http://nbviewer.ipython.org/github/CurricularAnalytics/ca-notebooks/tree/master/)**

## Frequently Asked Questions (FAQ)

### **How do I install Julia?**
Download the Current Stable Release of Julia for your operating system from https://julialang.org/downloads/ 

Detailed installation instructions for each operating system can be found at https://julialang.org/downloads/platform.html

### **How do I install the CurricularAnalytics.jl package?**
Open the Julia application. It should look similar to the image below. 

![Julia termain](https://s3.amazonaws.com/curricularanalytics.jl/julia-command-line.png)

Enter Pkg mode from within Julia by hitting `]`, and then type:
```julia-repl
pkg> add CurricularAnalytics
```
This will install the toolbox, along with the other Julia packages needed to run it.

### **How do I run notebooks on my machine?**
You must first install Jupyter, which can be done by following these steps: 

In the Julia terminal, enter Pkg mode by hitting `]`, and type:  
```julia-repl
pkg> add IJulia WebIO
```
Exit out of Pkg mode by hitting `Backspace` and type:  
```
julia> using WebIO
julia> WebIO.install_jupyter_nbextension()
```

In order to use the notebook, you will need to type:  
```
julia> using IJulia, WebIO
julia> notebook()
```

The first time you run `notebook()`, it will ask you if you would like to download Conda as well.  Hit Enter to reply yes and it will begin installing the Conda.jl package needed to run Jupyter. After allowing it to do so it will open Jupyter in your default web browser. You are now able to open and create IJulia notebooks.

If you wish to exit Jupyter, close the Jupyter tabs in your browser first. Then, in your Julia terminal, type: `Ctrl+C` to close the Jupyter Notebook server.

### **How do I download the notebooks from this repository?**
First, open the **[NBViewer link](http://nbviewer.ipython.org/github/CurricularAnalytics/ca-notebooks/tree/master/)** and navigate to the notebook you wish to download. In the upper right corner is a button to download the notebook, which is shown below.

![Download a noteobok](notebook-download.png)
Save the notebook to your machine, and then open it from Jupyter.