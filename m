Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 82D8B6B4CAF
	for <linux-mm@kvack.org>; Wed, 29 Aug 2018 12:44:42 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id l45-v6so3842051wre.4
        for <linux-mm@kvack.org>; Wed, 29 Aug 2018 09:44:42 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id x189-v6sor1393516wmg.10.2018.08.29.09.44.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 Aug 2018 09:44:40 -0700 (PDT)
MIME-Version: 1.0
References: <CADF2uSroEHML=v7hjQ=KLvK9cuP9=YcRUy9MiStDc0u+BxTApg@mail.gmail.com>
 <6ef03395-6baa-a6e5-0d5a-63d4721e6ec0@suse.cz> <20180823122111.GG29735@dhcp22.suse.cz>
 <CADF2uSpnYp31mr6q3Mnx0OBxCDdu6NFCQ=LTeG61dcfAJB5usg@mail.gmail.com>
 <76c6e92b-df49-d4b5-27f7-5f2013713727@suse.cz> <CADF2uSrNoODvoX_SdS3_127-aeZ3FwvwnhswoGDN0wNM2cgvbg@mail.gmail.com>
 <8b211f35-0722-cd94-1360-a2dd9fba351e@suse.cz> <CADF2uSoDFrEAb0Z-w19Mfgj=Tskqrjh_h=N6vTNLXcQp7jdTOQ@mail.gmail.com>
 <20180829150136.GA10223@dhcp22.suse.cz> <CADF2uSoViODBbp4OFHTBhXvgjOVL8ft1UeeaCQjYHZM0A=p-dA@mail.gmail.com>
 <20180829152716.GB10223@dhcp22.suse.cz>
In-Reply-To: <20180829152716.GB10223@dhcp22.suse.cz>
From: Marinko Catovic <marinko.catovic@gmail.com>
Date: Wed, 29 Aug 2018 18:44:27 +0200
Message-ID: <CADF2uSoG_RdKF0pNMBaCiPWGq3jn1VrABbm-rSnqabSSStixDw@mail.gmail.com>
Subject: Re: Caching/buffers become useless after some time
Content-Type: multipart/alternative; boundary="000000000000bd2c92057495acfb"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Christopher Lameter <cl@linux.com>, linux-mm@kvack.org

--000000000000bd2c92057495acfb
Content-Type: text/plain; charset="UTF-8"

> > one host is at a healthy state right now, I'd run that over there
> immediately.
>
> Let's see what we can get from here.
>

oh well, that went fast. actually with having low values for buffers
(around 100MB) with caches
around 20G or so, the performance was nevertheless super-low, I really had
to drop
the caches right now. This is the first time I see it with caches >10G
happening, but hopefully
this also provides a clue for you.

Just after starting the stats I reset from previously defer to madvise - I
suspect that this somehow
caused the rapid reaction, since a few minutes later I saw that the free
RAM jumped from 5GB to 10GB,
after that I went afk, returning to the pc since my monitoring systems went
crazy telling me about downtime.

If you think changing /sys/kernel/mm/transparent_hugepage/defrag back to
its default, while it was
on defer now for days, was a mistake, then please tell me.

here you go: https://nofile.io/f/VqRg644AT01/vmstat.tar.gz
trace_pipe: https://nofile.io/f/wFShvZScpvn/trace_pipe.gz

--000000000000bd2c92057495acfb
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_quote"><blockquote class=3D"gmail_=
quote" style=3D"margin:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,=
204);padding-left:1ex">
&gt; one host is at a healthy state right now, I&#39;d run that over there =
immediately.<br>
<br>
Let&#39;s see what we can get from here.<br></blockquote><div><br></div><di=
v><div>oh well, that went fast. actually with having low values for buffers=
 (around 100MB) with caches</div><div>around 20G or so, the performance was=
 nevertheless super-low, I really had to drop</div><div>the caches right no=
w. This is the first time I see it with caches &gt;10G happening, but hopef=
ully</div><div>this also provides a clue for you.<br></div><div><br></div><=
div>Just after starting the stats I reset from previously defer to madvise =
- I suspect that this somehow</div><div>caused the rapid reaction, since a =
few minutes later I saw that the free RAM jumped from 5GB to 10GB,</div><di=
v>after that I went afk, returning to the pc since my monitoring systems we=
nt crazy telling me about downtime.<br></div><div><br></div><div>If you thi=
nk changing /sys/kernel/mm/transparent_hugepage/defrag<span class=3D"gmail-=
im"> back to its default, while it was</span></div><div><span class=3D"gmai=
l-im">on defer now for days, was a mistake, then please tell me.</span></di=
v><div><span class=3D"gmail-im"><br></span></div><div><span class=3D"gmail-=
im">here you go: <a href=3D"https://nofile.io/f/VqRg644AT01/vmstat.tar.gz">=
https://nofile.io/f/VqRg644AT01/vmstat.tar.gz</a></span></div><div><span cl=
ass=3D"gmail-im">trace_pipe: <a href=3D"https://nofile.io/f/wFShvZScpvn/tra=
ce_pipe.gz">https://nofile.io/f/wFShvZScpvn/trace_pipe.gz</a><br></span></d=
iv>=C2=A0</div></div></div>

--000000000000bd2c92057495acfb--
