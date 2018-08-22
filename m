Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4AE856B2617
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 16:02:35 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id a37-v6so2779931wrc.5
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 13:02:35 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id h132-v6sor750282wme.22.2018.08.22.13.02.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 Aug 2018 13:02:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <11b4f8cd-6253-262f-4ae6-a14062c58039@suse.cz>
References: <CADF2uSr=mjVih1TB397bq1H7u3rPvo0HPqhUiG21AWu+WXFC5g@mail.gmail.com>
 <1f862d41-1e9f-5324-fb90-b43f598c3955@suse.cz> <CADF2uSrhKG=ntFWe96YyDWF8DFGyy4Jo4YFJFs=60CBXY52nfg@mail.gmail.com>
 <30f7ec9a-e090-06f1-1851-b18b3214f5e3@suse.cz> <CADF2uSocjT5Oz=1Wohahjf5-58YpT2Jm2vTQKuqA=8ywBFwCaQ@mail.gmail.com>
 <20180806120042.GL19540@dhcp22.suse.cz> <010001650fe29e66-359ffa28-9290-4e83-a7e2-b6d1d8d2ee1d-000000@email.amazonses.com>
 <20180806181638.GE10003@dhcp22.suse.cz> <CADF2uSqzt+u7vMkcD-vvT6tjz2bdHtrFK+p6s7NXGP-BJ34dRA@mail.gmail.com>
 <CADF2uSp7MKYWL7Yu5TDOT4qe0v-0iiq+Tv9J6rnzCSgahXbNaA@mail.gmail.com>
 <20180821064911.GW29735@dhcp22.suse.cz> <11b4f8cd-6253-262f-4ae6-a14062c58039@suse.cz>
From: Marinko Catovic <marinko.catovic@gmail.com>
Date: Wed, 22 Aug 2018 22:02:32 +0200
Message-ID: <CADF2uSroEHML=v7hjQ=KLvK9cuP9=YcRUy9MiStDc0u+BxTApg@mail.gmail.com>
Subject: Re: Caching/buffers become useless after some time
Content-Type: multipart/alternative; boundary="00000000000080eaf905740b9f9f"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@suse.com>, Christopher Lameter <cl@linux.com>, linux-mm@kvack.org

--00000000000080eaf905740b9f9f
Content-Type: text/plain; charset="UTF-8"

> It might be also interesting to do in the problematic state, instead of
> dropping caches:
>
> - save snapshot of /proc/vmstat and /proc/pagetypeinfo
> - echo 1 > /proc/sys/vm/compact_memory
> - save new snapshot of /proc/vmstat and /proc/pagetypeinfo

There was just a worstcase in progress, about 100MB/10GB were used,
super-low perfomance, but could not see any improvement there after echo 1,
I watches this for about 3 minutes, the cache usage did not change.

pagetypeinfo before echo https://pastebin.com/MjSgiMRL
pagetypeinfo 3min after echo https://pastebin.com/uWM6xGDd

vmstat before echo https://pastebin.com/TjYSKNdE
vmstat 3min after echo https://pastebin.com/MqTibEKi

> Btw. vast majority of order-3 requests come from the network layer. Are
> you using a large MTU (jumbo packets)?

not that I know of, how would I figure that out?
I have not touched sysctl net.* besides a few values not related to mtu
afaik

> Btw. I was probably not specific enough. This data should be collected
> _during_ the time when the page cache is disappearing. I suspect you
> have started collecting after the fact.

meh, I just messed up that output with the latest drop_caches, but I am
pretty
much sure that the one you see is while the usage was like 300MB/10GB,
before drop caches.

I was thinking maybe it would really help if one of you guys links up with
the hosts
in that state so that you can see for yourself. due to privacy issues (gdpr
and stuff)
I'd like to monitor this, so the ssh login would have to go over something
like teamviewer
on my host or whatever. please let me know if anyone is willing, since I
really see
no help there with anything I tried for 3 months by now. thanks for the
efforts.
surely any diagnosis would be easier this way.

--00000000000080eaf905740b9f9f
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_extra"><div class=3D"gmail_quote">&gt;=
 It might be also interesting to do in the problematic state, instead of<br=
>&gt;=20
dropping caches:<br>
&gt; <br>&gt;=20
- save snapshot of /proc/vmstat and /proc/pagetypeinfo<br>
&gt; - echo 1 &gt; /proc/sys/vm/compact_memory<br>&gt; - save new snapshot =
of /proc/vmstat and /proc/pagetypeinfo<br></div></div><div class=3D"gmail_e=
xtra"><br></div><div class=3D"gmail_extra">There was just a worstcase in pr=
ogress, about 100MB/10GB were used,</div><div class=3D"gmail_extra">super-l=
ow perfomance, but could not see any improvement there after echo 1,</div><=
div class=3D"gmail_extra">I watches this for about 3 minutes, the cache usa=
ge did not change.<br></div><div class=3D"gmail_extra"><br></div><div class=
=3D"gmail_extra">pagetypeinfo before echo <a href=3D"https://pastebin.com/M=
jSgiMRL">https://pastebin.com/MjSgiMRL</a></div><div class=3D"gmail_extra">=
pagetypeinfo 3min after echo <a href=3D"https://pastebin.com/uWM6xGDd">http=
s://pastebin.com/uWM6xGDd</a><br></div><div class=3D"gmail_extra"><br></div=
><div class=3D"gmail_extra">vmstat before echo <a href=3D"https://pastebin.=
com/TjYSKNdE">https://pastebin.com/TjYSKNdE</a></div><div class=3D"gmail_ex=
tra">vmstat 3min after echo <a href=3D"https://pastebin.com/MqTibEKi">https=
://pastebin.com/MqTibEKi</a><br></div><div class=3D"gmail_extra"><br>
&gt; Btw. vast majority of order-3 requests come from the network layer. Ar=
e<br>
&gt; you using a large MTU (jumbo packets)?<br></div><div class=3D"gmail_ex=
tra"><br></div><div class=3D"gmail_extra">not that I know of, how would I f=
igure that out?</div><div class=3D"gmail_extra">I have not touched sysctl n=
et.* besides a few values not related to mtu afaik</div><div class=3D"gmail=
_extra"><br></div><div class=3D"gmail_extra">&gt;=20
Btw. I was probably not specific enough. This data should be collected<br>
&gt; _during_ the time when the page cache is disappearing. I suspect you<b=
r>&gt; have started collecting after the fact.<br></div><div class=3D"gmail=
_extra"><br></div><div class=3D"gmail_extra">meh, I just messed up that out=
put with the latest drop_caches, but I am pretty</div><div class=3D"gmail_e=
xtra">much sure that the one you see is while the usage was like 300MB/10GB=
,</div><div class=3D"gmail_extra">before drop caches.</div><div class=3D"gm=
ail_extra"><br></div><div class=3D"gmail_extra">I was thinking maybe it wou=
ld really help if one of you guys links up with the hosts</div><div class=
=3D"gmail_extra">in that state so that you can see for yourself. due to pri=
vacy issues (gdpr and stuff)</div><div class=3D"gmail_extra">I&#39;d like t=
o monitor this, so the ssh login would have to go over something like teamv=
iewer</div><div class=3D"gmail_extra">on my host or whatever. please let me=
 know if anyone is willing, since I really see</div><div class=3D"gmail_ext=
ra">no help there with anything I tried for 3 months by now. thanks for the=
 efforts.</div><div class=3D"gmail_extra">surely any diagnosis would be eas=
ier this way.<br></div><div class=3D"gmail_extra"><br></div><div class=3D"g=
mail_extra"><br></div></div>

--00000000000080eaf905740b9f9f--
