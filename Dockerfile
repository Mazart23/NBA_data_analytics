FROM iszagh/cmdstan_python:2

WORKDIR /app

COPY ./requirements.txt /app/

RUN python -m ensurepip --upgrade
RUN python -m pip install --upgrade setuptools
#RUN python -m pip install jupyter

RUN python -m pip install -r requirements.txt

#COPY ./main.ipynb /app/project/
#COPY ./src /app/project/src/

#EXPOSE 8888
#
#CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root", "main.ipynb"]
CMD ["bash"]