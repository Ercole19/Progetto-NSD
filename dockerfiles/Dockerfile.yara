FROM nsdcourse/basenet
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y yara && \
    mkdir -p /opt/yara_rules && \
    echo 'rule EICAR { strings: $a = "EICAR-STANDARD-ANTIVIRUS-TEST-FILE" condition: $a }' > /opt/yara_rules/eicar.yar
    

CMD ["/bin/bash"]
