FROM nnurphy/ub

ENV HOME=/root LANG=zh_CN.UTF-8
ENV PATH=${HOME}/.local/bin:$PATH

WORKDIR ${HOME}

EXPOSE 8888

### Node
ENV NODE_HOME=/opt/node NODE_VERSION=12.16.3
ENV PATH=${NODE_HOME}/bin:$PATH
RUN set -ex \
  ; mkdir -p ${NODE_HOME} \
  ; wget -q -O- https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz \
    | tar xJ -C ${NODE_HOME} --strip-components 1 \
  ; chown -R root:root ${NODE_HOME} \
  #; mkdir -p ${NPM_HOME} \
  #; npm config set prefix ${NPM_HOME} \
  #; npm config set registry https://registry.npm.taobao.org \
  #; npm -g install http-server \
  ; npm cache clean -f
  #; cp -r /root/.zshrc.d /root/.zshrc ${HOME} \

### CONDA
ENV JUPYTER_ROOT='' JUPYTER_PASSWORD='asdf'
ENV CONDA_HOME=/opt/conda tf_version=2.2.0
ENV PATH=${CONDA_HOME}/bin:$PATH
RUN set -ex \
  ; wget -q -O miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
  #; wget -q -O miniconda.sh https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-latest-Linux-x86_64.sh \
  ; bash ./miniconda.sh -b -p ${CONDA_HOME} \
  ; rm ./miniconda.sh \
  #; conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/ \
  #  && conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/ \
  #  && conda config --set show_channel_urls yes \
  ; conda clean --all -f -y \
  ; ln -s ${CONDA_HOME}/etc/profile.d/conda.sh /etc/profile.d/conda.sh \
  ; echo ". ${CONDA_HOME}/etc/profile.d/conda.sh" >> ~/.bashrc \
  ; echo "conda activate base" >> ~/.bashrc \
  ; conda update --all \
  ; conda install IPython ipykernel ipyparallel jupyter jupyterlab jupyterlab_launcher \
  ##################### RUN set -ex \
  ; conda install \
        SciPy Numpy numpydoc Scikit-learn scikit-image Pandas numba \
        matplotlib Seaborn Bokeh \
        Statsmodels SymPy Gensim numexpr NLTK networkx \
        # Keras TensorFlow <PyMC>
        Requests furl html5lib \
        PyParsing decorator more-itertools \
        fabric chardet click \
        sqlite psycopg2 pyyaml cloudpickle datashape libxml2 libxslt libuuid \
        xz zlib zstd snappy \
        ca-certificates cryptography pyjwt \
        cffi zeromq libssh2 openssl blaze pyzmq pcre \
  ; conda clean --all -f -y \
  #; pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple \
  ; pip --no-cache-dir install \
        tensorflow==${tf_version} \
        fastapi uvicorn \
        bash_kernel ipython-sql pgspecial jieba sh cachetools \
        config envelopes transitions chronyk queries fn.py \
  ; python -m bash_kernel.install \
  ; jupyter notebook --generate-config \
  ; jupyter_cfg=$HOME/.jupyter/jupyter_notebook_config.py \
  ; echo "import os\nfrom IPython.lib import passwd\n" >> $jupyter_cfg \
  ; echo 'c.NotebookApp.terminado_settings = { "shell_command": ["/bin/zsh"] }' >> $jupyter_cfg \
  ; echo 'c.NotebookApp.password = passwd(os.getenv("JUPYTER_PASSWORD"))' >> $jupyter_cfg \
  ; echo 'c.ContentsManager.root_dir = os.getenv("JUPYTER_ROOT")' >> $jupyter_cfg \
  ; echo 'c.NotebookApp.allow_root = True' >> $jupyter_cfg \
  ; echo 'c.NotebookApp.open_browser = False' >> $jupyter_cfg


RUN set -ex \
  ; jupyter labextension install @jupyterlab/git \
  ; jupyter labextension install jupyterlab-emacskeys \
  ; pip --no-cache-dir install jupyterlab-git \
  ; jupyter serverextension enable --py jupyterlab_git \
  #; jupyter labextension install @jupyterlab/celltags \
  ; jupyter labextension install jupyterlab-drawio \
  #; jupyter labextension install @krassowski/jupyterlab_go_to_definition \
  ; jupyter labextension install @jupyterlab/toc \
  ; rm -rf /usr/local/share/.cache/yarn \
  ; npm cache clean -f

# ENTRYPOINT [ "/usr/bin/tini", "--" ]
CMD [ "jupyter", "lab", "--ip", "0.0.0.0"]
