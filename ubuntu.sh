BootStrap: debootstrap
OSVersion: trusty
MirrorURL: http://us.archive.ubuntu.com/ubuntu/

%environment
    PATH="/apps/prophet:/apps/miniconda/bin:$PATH"

%runscript
    exec ProphET_standalone.pl

%post
    echo "Hello from inside the container"
    sed -i 's/$/ universe/' /etc/apt/sources.list

    #essential stuff
    apt -y --force-yes install git sudo man vim build-essential wget unzip curl autoconf libtool pkg-config libgd2-xpm-dev subversion
 
    mkdir /apps
    cd /apps
 
    #bioconda GOOOD
    wget https://repo.continuum.io/miniconda/Miniconda2-latest-Linux-x86_64.sh
    bash Miniconda2-latest-Linux-x86_64.sh -b -p /apps/miniconda
    rm Miniconda2-latest-Linux-x86_64.sh
    sudo ln -s /apps/miniconda/bin/python2.7 /usr/bin/python
    PATH="/apps/miniconda/bin:$PATH"
    conda install -y -c bioconda blast-legacy
    conda install -y -c bioconda emboss
    conda install -y -c bioconda bedtools
 
    #so we dont get those stupid perl warnings
    locale-gen en_US.UTF-8
    
    #cpanminus for zero-config cpan
    wget -O - http://cpanmin.us | perl - --self-upgrade

    #Perl-modules for prophet
    cpanm Bio::Perl
    cpanm SVG
    cpanm GD
    cpanm GD::SVG
    cpanm Bio::Graphics
    cpanm LWP::Simple
    cpanm XML::Simple

    git clone https://github.com/jaumlrc/ProphET.git prophet
    cd prophet
    ./INSTALL.pl

    #cleanup    
    conda clean -a -y

    #create a directory to work in
    mkdir /work
    #so we dont get those stupid worning on hpc/pbs
    mkdir /extra
    mkdir /xdisk

%test
    cd /apps/prophet && ./ProphET_standalone.pl --fasta test.fasta --gff_in test.gff --outdir test
