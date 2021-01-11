FROM nnurphy/ub

ENV LANG=zh_CN.UTF-8
ENV HOME=/root
ENV PATH=${HOME}/.local/bin:$PATH

WORKDIR ${HOME}

EXPOSE 8888

### CONDA
ENV JUPYTER_ROOT='' JUPYTER_PASSWORD='asdf'
ENV CONDA_HOME=/opt/conda
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
  ; conda install -c conda-forge -y IPython ipykernel ipyparallel jupyter jupyterlab=3 \
  ##################### RUN set -ex \
  ; conda install -y \
        SciPy Numpy numpydoc Scikit-learn scikit-image Pandas numba \
        matplotlib Seaborn Bokeh \
        Statsmodels SymPy numexpr NLTK networkx \
        # Keras TensorFlow <PyMC>
        sqlite psycopg2 pyyaml cloudpickle datashape libxml2 libxslt libuuid \
        xz zlib zstd snappy \
        ca-certificates cryptography pyjwt \
        cffi zeromq libssh2 openssl pyzmq pcre \
  ; conda clean --all -f -y \
  #; pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple \
  ; pip --no-cache-dir install ptvsd neovim \
        torch pytorch-lightning \
        fabric typer hydra-core \
        pyparsing decorator more-itertools \
        Requests furl html5lib \
        fastapi uvicorn aiohttp aiohttp-requests \
        bash_kernel ipython-sql pgspecial jieba sh cachetools \
        typer hydra-core envelopes transitions chronyk fn.py \
  ; python -m bash_kernel.install \
  ; jupyter lab --generate-config \
  ; jupyter_cfg=$HOME/.jupyter/jupyter_lab_config.py \
  ; echo "import os\nfrom IPython.lib import passwd\n" >> $jupyter_cfg \
  ; echo 'c.ServerApp.terminado_settings = { "shell_command": ["/bin/zsh"] }' >> $jupyter_cfg \
  ; echo 'c.ServerApp.password = passwd(os.getenv("JUPYTER_PASSWORD"))' >> $jupyter_cfg \
  ; echo 'c.ServerApp.root_dir = os.getenv("JUPYTER_ROOT")' >> $jupyter_cfg \
  ; echo 'c.ServerApp.allow_root = True' >> $jupyter_cfg \
  ; echo 'c.ServerApp.ip = "0.0.0.0"' >> $jupyter_cfg \
  ; echo 'c.ExtensionApp.open_browser = False' >> $jupyter_cfg


RUN set -ex \
  ; jupyter labextension install @axlair/jupyterlab_vim \
  #; pip --no-cache-dir install --upgrade jupyterlab-git \
  #; jupyter lab build \
  #; jupyter serverextension enable --py jupyterlab_git \
  #; jupyter labextension install @jupyterlab/git \
  #; jupyter labextension install jupyterlab-drawio \
  #; jupyter labextension install @krassowski/jupyterlab_go_to_definition \
  ; rm -rf /usr/local/share/.cache/yarn \
  ; npm cache clean -f

RUN set -eux \
  ; nvim_home=/etc/skel/.config/nvim \
  ; SKIP_CYTHON_BUILD=1 $nvim_home/plugged/vimspector/install_gadget.py --enable-python \
  ; rm -f $nvim_home/plugged/vimspector/gadgets/linux/download/debugpy/*/*.zip

# ENTRYPOINT [ "/usr/bin/tini", "--" ]
CMD [ "jupyter", "lab"]
