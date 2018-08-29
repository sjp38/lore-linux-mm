Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id EF9936B4C24
	for <linux-mm@kvack.org>; Wed, 29 Aug 2018 10:54:45 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id s18-v6so3063432wmc.5
        for <linux-mm@kvack.org>; Wed, 29 Aug 2018 07:54:45 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id m2-v6sor2985429wrj.18.2018.08.29.07.54.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 Aug 2018 07:54:44 -0700 (PDT)
MIME-Version: 1.0
References: <CADF2uSocjT5Oz=1Wohahjf5-58YpT2Jm2vTQKuqA=8ywBFwCaQ@mail.gmail.com>
 <20180806120042.GL19540@dhcp22.suse.cz> <010001650fe29e66-359ffa28-9290-4e83-a7e2-b6d1d8d2ee1d-000000@email.amazonses.com>
 <20180806181638.GE10003@dhcp22.suse.cz> <CADF2uSqzt+u7vMkcD-vvT6tjz2bdHtrFK+p6s7NXGP-BJ34dRA@mail.gmail.com>
 <CADF2uSp7MKYWL7Yu5TDOT4qe0v-0iiq+Tv9J6rnzCSgahXbNaA@mail.gmail.com>
 <20180821064911.GW29735@dhcp22.suse.cz> <11b4f8cd-6253-262f-4ae6-a14062c58039@suse.cz>
 <CADF2uSroEHML=v7hjQ=KLvK9cuP9=YcRUy9MiStDc0u+BxTApg@mail.gmail.com>
 <6ef03395-6baa-a6e5-0d5a-63d4721e6ec0@suse.cz> <20180823122111.GG29735@dhcp22.suse.cz>
 <CADF2uSpnYp31mr6q3Mnx0OBxCDdu6NFCQ=LTeG61dcfAJB5usg@mail.gmail.com>
 <76c6e92b-df49-d4b5-27f7-5f2013713727@suse.cz> <CADF2uSrNoODvoX_SdS3_127-aeZ3FwvwnhswoGDN0wNM2cgvbg@mail.gmail.com>
 <8b211f35-0722-cd94-1360-a2dd9fba351e@suse.cz>
In-Reply-To: <8b211f35-0722-cd94-1360-a2dd9fba351e@suse.cz>
From: Marinko Catovic <marinko.catovic@gmail.com>
Date: Wed, 29 Aug 2018 16:54:32 +0200
Message-ID: <CADF2uSoDFrEAb0Z-w19Mfgj=Tskqrjh_h=N6vTNLXcQp7jdTOQ@mail.gmail.com>
Subject: Re: Caching/buffers become useless after some time
Content-Type: multipart/alternative; boundary="0000000000009238ef0574942314"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@suse.com>, Christopher Lameter <cl@linux.com>, linux-mm@kvack.org

--0000000000009238ef0574942314
Content-Type: text/plain; charset="UTF-8"

> > shall I switch it to defer and observe (all hosts are running fine by
> > just now) or
> > switch to defer while it is in the bad state?
>
> You could do it immediately and see if no problems appear for long
> enough, OTOH...
>

well cat /sys/kernel/mm/transparent_hugepage/defrag
always [defer] defer+madvise madvise never
was active now since your reply, however, I can not tell that it helped.

This was set on 2 hosts, one has 20GB of unused RAM now.
Yesterday there was a similar picture for both, with several GB, one with
up to 10GB unused,
I just checked once, this is what I recall.

tell me if one would like to login remotely, I can set up teamviewer or
something for this
at any time, just drop a message here and I'll contact you.
I have hopes that one can investigate things even on that host that has
20GB unused, it's just
a matter of time until this gets to the low values, surely the problem here
already kicked in.

Also if the remote login is not an option, I'm always happy to provide
whatever info you need.

--0000000000009238ef0574942314
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_quote"><blockquote class=3D"gmail_=
quote" style=3D"margin:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,=
204);padding-left:1ex">
&gt; shall I switch it to defer and observe (all hosts are running fine by<=
br>
&gt; just now) or<br>
&gt; switch to defer while it is in the bad state?<br>
<br>
You could do it immediately and see if no problems appear for long<br>
enough, OTOH...<br></blockquote><div><br></div><div>well cat /sys/kernel/mm=
/transparent_hugepage/defrag<br>always [defer] defer+madvise madvise never<=
/div><div>was active now since your reply, however, I can not tell that it =
helped.</div><div><br></div><div>This was set on 2 hosts, one has 20GB of u=
nused RAM now.</div><div>Yesterday there was a similar picture for both, wi=
th several GB, one with up to 10GB unused,</div><div>I just checked once, t=
his is what I recall.</div><div><br></div><div>tell me if one would like to=
 login remotely, I can set up teamviewer or something for this</div><div>at=
 any time, just drop a message here and I&#39;ll contact you.</div><div>I h=
ave hopes that one can investigate things even on that host that has 20GB u=
nused, it&#39;s just</div><div>a matter of time until this gets to the low =
values, surely the problem here already kicked in.</div><div><br></div><div=
>Also if the remote login is not an option, I&#39;m always happy to provide=
 whatever info you need.</div><div><br></div><div><br></div><div><br></div>=
</div></div>

--0000000000009238ef0574942314--
