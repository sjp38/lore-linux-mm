Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f174.google.com (mail-qk0-f174.google.com [209.85.220.174])
	by kanga.kvack.org (Postfix) with ESMTP id 2C2456B0038
	for <linux-mm@kvack.org>; Fri, 18 Sep 2015 17:28:38 -0400 (EDT)
Received: by qkcf65 with SMTP id f65so24883729qkc.3
        for <linux-mm@kvack.org>; Fri, 18 Sep 2015 14:28:38 -0700 (PDT)
Received: from mail-qg0-f51.google.com (mail-qg0-f51.google.com. [209.85.192.51])
        by mx.google.com with ESMTPS id 79si9950916qgc.83.2015.09.18.14.28.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Sep 2015 14:28:37 -0700 (PDT)
Received: by qgev79 with SMTP id v79so49426186qge.0
        for <linux-mm@kvack.org>; Fri, 18 Sep 2015 14:28:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.11.1509181417220.12714@east.gentwo.org>
References: <1442512783-14719-1-git-send-email-kwalker@redhat.com>
	<20150917192204.GA2728@redhat.com>
	<alpine.DEB.2.11.1509181035180.11189@east.gentwo.org>
	<20150918162423.GA18136@redhat.com>
	<alpine.DEB.2.11.1509181200140.11964@east.gentwo.org>
	<20150918190725.GA24989@redhat.com>
	<alpine.DEB.2.11.1509181417220.12714@east.gentwo.org>
Date: Fri, 18 Sep 2015 17:28:36 -0400
Message-ID: <CAEPKNT+H28BdJxb12MfFSrtoA8jkGX5WGSPGpH4ejRDbCQZFXQ@mail.gmail.com>
Subject: Re: [PATCH] mm/oom_kill.c: don't kill TASK_UNINTERRUPTIBLE tasks
From: Kyle Walker <kwalker@redhat.com>
Content-Type: multipart/alternative; boundary=001a113a8a1af1989c05200c3603
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Oleg Nesterov <oleg@redhat.com>, akpm@linux-foundation.org, mhocko@suse.cz, rientjes@google.com, hannes@cmpxchg.org, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Stanislav Kozina <skozina@redhat.com>

--001a113a8a1af1989c05200c3603
Content-Type: text/plain; charset=UTF-8

> On Fri, 18 Sep 2015, Oleg Nesterov wrote:
> > And btw. Yes, this is a bit off-topic, but I think another change make
> > sense too. We should report the fact we are going to kill another task
> > because the previous victim refuse to die, and print its stack trace.

Thank you for the review and feedback! I think that would definitely be a
nice touch. I would definitely throw my hat in as wanting the above, but in
the interests of keeping things as simple as possible, I kept myself out of
that level of change.

> What happens is that the previous victim did not enter exit processing. If
> it would then it would be excluded by other checks. The first victim never
> reacted and never started using the memory resources available for
> exiting. Thats why I thought it maybe safe to go this way.
>
> An issue could result from another process being terminated and the first
> victim finally reacting to the signal and also beginning termination. Then
> we have contention on the reserves.
>

I do like the idea of not stalling completely in an oom just because the
first attempt didn't go so well. Is there any possibility of simply having
our cake and eating it too? Specifically, omitting TASK_UNINTERRUPTIBLE
tasks
as low-hanging fruit and allowing the oom to continue in the event that the
first attempt stalls?

Just a thought.

--001a113a8a1af1989c05200c3603
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_default" style=3D""><font face=3D"mono=
space, monospace">&gt; On Fri, 18 Sep 2015, Oleg Nesterov wrote:</font></di=
v><div class=3D"gmail_default" style=3D""><font face=3D"monospace, monospac=
e">&gt; &gt; And btw. Yes, this is a bit off-topic, but I think another cha=
nge make</font></div><div class=3D"gmail_default" style=3D""><font face=3D"=
monospace, monospace">&gt; &gt; sense too. We should report the fact we are=
 going to kill another task</font></div><div class=3D"gmail_default" style=
=3D""><font face=3D"monospace, monospace">&gt; &gt; because the previous vi=
ctim refuse to die, and print its stack trace.</font></div><div class=3D"gm=
ail_default" style=3D""><font face=3D"monospace, monospace"><br></font></di=
v><div class=3D"gmail_default" style=3D""><font face=3D"monospace, monospac=
e">Thank you for the review and feedback! I think that would definitely be =
a</font></div><div class=3D"gmail_default" style=3D""><font face=3D"monospa=
ce, monospace">nice touch. I would definitely throw my hat in as wanting th=
e above, but in</font></div><div class=3D"gmail_default" style=3D""><font f=
ace=3D"monospace, monospace">the interests of keeping things as simple as p=
ossible, I kept myself out of</font></div><div class=3D"gmail_default" styl=
e=3D""><font face=3D"monospace, monospace">that level of change.</font></di=
v><div class=3D"gmail_default" style=3D""><font face=3D"monospace, monospac=
e"><br></font></div><div class=3D"gmail_default" style=3D""><font face=3D"m=
onospace, monospace">&gt; What happens is that the previous victim did not =
enter exit processing. If</font></div><div class=3D"gmail_default" style=3D=
""><font face=3D"monospace, monospace">&gt; it would then it would be exclu=
ded by other checks. The first victim never</font></div><div class=3D"gmail=
_default" style=3D""><font face=3D"monospace, monospace">&gt; reacted and n=
ever started using the memory resources available for=C2=A0</font></div><di=
v class=3D"gmail_default" style=3D""><font face=3D"monospace, monospace">&g=
t; exiting. Thats why I thought it maybe safe to go this way.</font></div><=
div class=3D"gmail_default" style=3D""><font face=3D"monospace, monospace">=
&gt;</font></div><div class=3D"gmail_default" style=3D""><font face=3D"mono=
space, monospace">&gt; An issue could result from another process being ter=
minated and the first</font></div><div class=3D"gmail_default" style=3D""><=
font face=3D"monospace, monospace">&gt; victim finally reacting to the sign=
al and also beginning termination. Then</font></div><div class=3D"gmail_def=
ault" style=3D""><font face=3D"monospace, monospace">&gt; we have contentio=
n on the reserves.</font></div><div class=3D"gmail_default" style=3D""><fon=
t face=3D"monospace, monospace">&gt;</font></div><div class=3D"gmail_defaul=
t" style=3D""><font face=3D"monospace, monospace"><br></font></div><div cla=
ss=3D"gmail_default" style=3D""><font face=3D"monospace, monospace">I do li=
ke the idea of not stalling completely in an oom just because the</font></d=
iv><div class=3D"gmail_default" style=3D""><font face=3D"monospace, monospa=
ce">first attempt didn&#39;t go so well. Is there any possibility of simply=
 having</font></div><div class=3D"gmail_default" style=3D""><font face=3D"m=
onospace, monospace">our cake and eating it too? Specifically, omitting TAS=
K_UNINTERRUPTIBLE tasks</font></div><div class=3D"gmail_default" style=3D""=
><font face=3D"monospace, monospace">as low-hanging fruit and allowing the =
oom to continue in the event that the</font></div><div class=3D"gmail_defau=
lt" style=3D""><font face=3D"monospace, monospace">first attempt stalls?</f=
ont></div><div class=3D"gmail_default" style=3D""><font face=3D"monospace, =
monospace"><br></font></div><div class=3D"gmail_default" style=3D""><font f=
ace=3D"monospace, monospace">Just a thought.</font></div><div class=3D"gmai=
l_default" style=3D"font-family:monospace,monospace"></div><div class=3D"gm=
ail_extra">
</div></div>

--001a113a8a1af1989c05200c3603--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
