Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f47.google.com (mail-lf0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id 24B636B007E
	for <linux-mm@kvack.org>; Fri,  8 Apr 2016 15:51:20 -0400 (EDT)
Received: by mail-lf0-f47.google.com with SMTP id e190so87824954lfe.0
        for <linux-mm@kvack.org>; Fri, 08 Apr 2016 12:51:20 -0700 (PDT)
Received: from mail-lf0-x22d.google.com (mail-lf0-x22d.google.com. [2a00:1450:4010:c07::22d])
        by mx.google.com with ESMTPS id a10si7744432lbx.55.2016.04.08.12.51.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Apr 2016 12:51:18 -0700 (PDT)
Received: by mail-lf0-x22d.google.com with SMTP id c126so89653569lfb.2
        for <linux-mm@kvack.org>; Fri, 08 Apr 2016 12:51:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160408165051.GB16346@kroah.com>
References: <1460129004-2011-1-git-send-email-rsalvaterra@gmail.com>
	<20160408165051.GB16346@kroah.com>
Date: Fri, 8 Apr 2016 20:51:17 +0100
Message-ID: <CALjTZvYS5s0uyH_HxbG970Zans0uYzj5g6Wj2M2YUjfL_v8Xog@mail.gmail.com>
Subject: Re: [PATCH] lib: lz4: fixed zram with lz4 on big endian machines
From: Rui Salvaterra <rsalvaterra@gmail.com>
Content-Type: multipart/alternative; boundary=001a11c36bdcafa988052ffe84d4
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <gregkh@linuxfoundation.org>
Cc: Chanho Min <chanho.min@lge.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, eunb.song@samsung.com, linux-kernel@vger.kernel.org, kyungsik.lee@lge.com, stable@vger.kernel.org, minchan@kernel.org, sergey.senozhatsky@gmail.com, linux-mm@kvack.org

--001a11c36bdcafa988052ffe84d4
Content-Type: text/plain; charset=UTF-8

On 8 Apr 2016 17:50, "Greg KH" <gregkh@linuxfoundation.org> wrote:
>
> On Fri, Apr 08, 2016 at 04:23:24PM +0100, Rui Salvaterra wrote:
> > Based on Sergey's test patch [1], this fixes zram with lz4 compression
on big endian cpus. Tested on ppc64 with no regression on x86_64.
>
> Please wrap your text at 72 columns in a changelog comment.
>
> >
> > [1] http://marc.info/?l=linux-kernel&m=145994470805853&w=4
> >
> > Cc: stable@vger.kernel.org
> > Signed-off-by: Rui Salvaterra <rsalvaterra@gmail.com>
>
> Please attribute Sergey here in the signed-off-by area with a
> "Suggested-by:" type mark
>
> > ---
> >  lib/lz4/lz4defs.h | 29 +++++++++++++++--------------
> >  1 file changed, 15 insertions(+), 14 deletions(-)
> >
> > diff --git a/lib/lz4/lz4defs.h b/lib/lz4/lz4defs.h
> > index abcecdc..a98c08c 100644
> > --- a/lib/lz4/lz4defs.h
> > +++ b/lib/lz4/lz4defs.h
> > @@ -11,8 +11,7 @@
> >  /*
> >   * Detects 64 bits mode
> >   */
> > -#if (defined(__x86_64__) || defined(__x86_64) || defined(__amd64__) \
> > -     || defined(__ppc64__) || defined(__LP64__))
> > +#if defined(CONFIG_64BIT)
>
> This patch seems to do two different things, clean up the #if tests, and
> change the endian of some calls.  Can you break this up into 2 different
> patches?
>
> thanks,
>
> greg k-h

Hi Greg,

Thanks for the review (and patience). The 64-bit #if test is actually part
of the fix, since __ppc64__ isn't defined anywhere and we'd fall into the
32-bit definitions for ppc64. I can send the other one separately, for
sure. I'll do a v2 tomorrow.

Thanks,

Rui

--001a11c36bdcafa988052ffe84d4
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<p dir=3D"ltr"><br>
On 8 Apr 2016 17:50, &quot;Greg KH&quot; &lt;<a href=3D"mailto:gregkh@linux=
foundation.org">gregkh@linuxfoundation.org</a>&gt; wrote:<br>
&gt;<br>
&gt; On Fri, Apr 08, 2016 at 04:23:24PM +0100, Rui Salvaterra wrote:<br>
&gt; &gt; Based on Sergey&#39;s test patch [1], this fixes zram with lz4 co=
mpression on big endian cpus. Tested on ppc64 with no regression on x86_64.=
<br>
&gt;<br>
&gt; Please wrap your text at 72 columns in a changelog comment.<br>
&gt;<br>
&gt; &gt;<br>
&gt; &gt; [1]<a href=3D"http://marc.info/?l=3Dlinux-kernel&amp;m=3D14599447=
0805853&amp;w=3D4"> http://marc.info/?l=3Dlinux-kernel&amp;m=3D145994470805=
853&amp;w=3D4</a><br>
&gt; &gt;<br>
&gt; &gt; Cc:<a href=3D"mailto:stable@vger.kernel.org"> stable@vger.kernel.=
org</a><br>
&gt; &gt; Signed-off-by: Rui Salvaterra &lt;<a href=3D"mailto:rsalvaterra@g=
mail.com">rsalvaterra@gmail.com</a>&gt;<br>
&gt;<br>
&gt; Please attribute Sergey here in the signed-off-by area with a<br>
&gt; &quot;Suggested-by:&quot; type mark<br>
&gt;<br>
&gt; &gt; ---<br>
&gt; &gt;=C2=A0 lib/lz4/lz4defs.h | 29 +++++++++++++++--------------<br>
&gt; &gt;=C2=A0 1 file changed, 15 insertions(+), 14 deletions(-)<br>
&gt; &gt;<br>
&gt; &gt; diff --git a/lib/lz4/lz4defs.h b/lib/lz4/lz4defs.h<br>
&gt; &gt; index abcecdc..a98c08c 100644<br>
&gt; &gt; --- a/lib/lz4/lz4defs.h<br>
&gt; &gt; +++ b/lib/lz4/lz4defs.h<br>
&gt; &gt; @@ -11,8 +11,7 @@<br>
&gt; &gt;=C2=A0 /*<br>
&gt; &gt;=C2=A0 =C2=A0* Detects 64 bits mode<br>
&gt; &gt;=C2=A0 =C2=A0*/<br>
&gt; &gt; -#if (defined(__x86_64__) || defined(__x86_64) || defined(__amd64=
__) \<br>
&gt; &gt; -=C2=A0 =C2=A0 =C2=A0|| defined(__ppc64__) || defined(__LP64__))<=
br>
&gt; &gt; +#if defined(CONFIG_64BIT)<br>
&gt;<br>
&gt; This patch seems to do two different things, clean up the #if tests, a=
nd<br>
&gt; change the endian of some calls.=C2=A0 Can you break this up into 2 di=
fferent<br>
&gt; patches?<br>
&gt;<br>
&gt; thanks,<br>
&gt;<br>
&gt; greg k-h</p>
<p dir=3D"ltr">Hi Greg,</p>
<p dir=3D"ltr">Thanks for the review (and patience). The 64-bit #if test is=
 actually part of the fix, since __ppc64__ isn&#39;t defined anywhere and w=
e&#39;d fall into the 32-bit definitions for ppc64. I can send the other on=
e separately, for sure. I&#39;ll do a v2 tomorrow.</p>
<p dir=3D"ltr">Thanks,</p>
<p dir=3D"ltr">Rui</p>

--001a11c36bdcafa988052ffe84d4--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
