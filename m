Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3338E6B002C
	for <linux-mm@kvack.org>; Sat,  7 Apr 2018 16:38:05 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id u9-v6so1031112lfu.5
        for <linux-mm@kvack.org>; Sat, 07 Apr 2018 13:38:05 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f69-v6sor3153620lfe.37.2018.04.07.13.38.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 07 Apr 2018 13:38:03 -0700 (PDT)
MIME-Version: 1.0
References: <20180407184726.8634-1-paulmcquad@gmail.com> <03c43ed43d0ec3ab42940bfffd4c3778bf5d0f11.camel@perches.com>
In-Reply-To: <03c43ed43d0ec3ab42940bfffd4c3778bf5d0f11.camel@perches.com>
From: Paul Mc Quade <paulmcquad@gmail.com>
Date: Sat, 07 Apr 2018 20:37:52 +0000
Message-ID: <CAKi5BqYCaxsuuOQtfXqyd+ddf=8ggLB89HQ5TWky6JOq_xxOKA@mail.gmail.com>
Subject: Re: [PATCH 1/3] mm: replace S_IRUGO with 0444
Content-Type: multipart/alternative; boundary="00000000000033db28056948262b"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: konrad.wilk@oracle.com, labbott@redhat.com, gregkh@linuxfoundation.org, akpm@linux-foundation.org, guptap@codeaurora.org, vbabka@suse.cz, mgorman@techsingularity.net, hannes@cmpxchg.org, rientjes@google.com, mhocko@suse.com, rppt@linux.vnet.ibm.com, dave@stgolabs.net, hmclauchlan@fb.com, tglx@linutronix.de, pombredanne@nexb.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

--00000000000033db28056948262b
Content-Type: text/plain; charset="UTF-8"

Cool, thanks! I didn't know that.

On Sat 7 Apr 2018, 21:11 Joe Perches <joe@perches.com> wrote:

> On Sat, 2018-04-07 at 19:47 +0100, Paul McQuade wrote:
> > Fix checkpatch warnings about S_IRUGO being less readable than
> > providing the permissions octal as '0444'.
>
> Hey Paul.
>
> I sent a cleanup a couple weeks ago to Andrew Morton for the
> same thing.
>
> https://lkml.org/lkml/2018/3/26/638
>
> Andrew said he'd wait until after -rc1 is out.
>
> btw: checkpatch can do this substitution automatically
>
> cheers, Joe
>

--00000000000033db28056948262b
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"auto">Cool, thanks! I didn&#39;t know that.=C2=A0</div><br><div=
 class=3D"gmail_quote"><div dir=3D"ltr">On Sat 7 Apr 2018, 21:11 Joe Perche=
s &lt;<a href=3D"mailto:joe@perches.com">joe@perches.com</a>&gt; wrote:<br>=
</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-l=
eft:1px #ccc solid;padding-left:1ex">On Sat, 2018-04-07 at 19:47 +0100, Pau=
l McQuade wrote:<br>
&gt; Fix checkpatch warnings about S_IRUGO being less readable than<br>
&gt; providing the permissions octal as &#39;0444&#39;.<br>
<br>
Hey Paul.<br>
<br>
I sent a cleanup a couple weeks ago to Andrew Morton for the<br>
same thing.<br>
<br>
<a href=3D"https://lkml.org/lkml/2018/3/26/638" rel=3D"noreferrer noreferre=
r" target=3D"_blank">https://lkml.org/lkml/2018/3/26/638</a><br>
<br>
Andrew said he&#39;d wait until after -rc1 is out.<br>
<br>
btw: checkpatch can do this substitution automatically<br>
<br>
cheers, Joe<br>
</blockquote></div>

--00000000000033db28056948262b--
