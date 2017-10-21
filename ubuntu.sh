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
    apt -y --force-yes install git sudo man vim build-essential wget unzip

    #maybe dont need, add later if do:
    #curl autoconf libtool 
 
    mkdir /apps
    cd /apps
 
    #bioconda GOOOD
    wget https://repo.continuum.io/miniconda/Miniconda2-latest-Linux-x86_64.sh
    bash Miniconda2-latest-Linux-x86_64.sh -b -p /apps/miniconda
    rm Miniconda2-latest-Linux-x86_64.sh
    sudo ln -s /apps/miniconda/bin/python2.7 /usr/bin/python
    PATH="/apps/miniconda/bin:$PATH"
    conda install -y -c bioconda blast
    conda install -y -c bioconda emboss
    conda install -y -c bioconda bedtools
  
    #Perl-modules for prophet
    perl -MCPAN -e 'install Bio::Perl'
    perl -MCPAN -e 'install SVG'
    perl -MCPAN -e 'install GD'
    perl -MCPAN -e 'install GD::SVG'
    perl -MCPAN -e 'install Bio::Graphics'
    perl -MCPAN -e 'install LWP::Simple'
    perl -MCPAN -e 'install XML::Simple'

    git clone https://github.com/jaumlrc/ProphET.git prophet
    cd prophet
    ./INSTALL.pl

    #cleanup    

    #create a directory to work in
    mkdir /work

    #so we dont get those stupid perl warnings
    locale-gen en_US.UTF-8

    #so we dont get those stupid worning on hpc/pbs
    mkdir /extra
    mkdir /xdisk

%test
    cd /apps/prophet && ./ProphET_standalone.pl --fasta test.fasta --gff_in test.gff --outdir test
