Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id BC7AB6B0038
	for <linux-mm@kvack.org>; Thu, 21 Dec 2017 20:29:33 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id l33so15827544wrl.5
        for <linux-mm@kvack.org>; Thu, 21 Dec 2017 17:29:33 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id l13sor11554401edj.1.2017.12.21.17.29.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 21 Dec 2017 17:29:32 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1513902570.3132.22.camel@HansenPartnership.com>
References: <b1415a6d-fccd-31d0-ffa2-9b54fa699692@redhat.com>
 <20171221130057.GA26743@wolff.to> <CAA70yB6Z=r+zO7E+ZP74jXNk_XM2CggYthAD=TKOdBVsHLLV-w@mail.gmail.com>
 <20171221151843.GA453@wolff.to> <CAA70yB496Nuy2FM5idxLZthBwOVbhtsZ4VtXNJ_9mj2cvNC4kA@mail.gmail.com>
 <20171221153631.GA2300@wolff.to> <CAA70yB6nD7CiDZUpVPy7cGhi7ooQ5SPkrcXPDKqSYD2ezLrGHA@mail.gmail.com>
 <20171221164221.GA23680@wolff.to> <14f04d43-728a-953f-e07c-e7f9d5e3392d@kernel.dk>
 <1513902570.3132.22.camel@HansenPartnership.com>
From: weiping zhang <zwp10758@gmail.com>
Date: Fri, 22 Dec 2017 09:29:31 +0800
Message-ID: <CAA70yB6nQxjtsRhKEv_z4bgQ5sGW=Ej-i=je2D+cwMgoGPDF9Q@mail.gmail.com>
Subject: Re: Regression with a0747a859ef6 ("bdi: add error handle for bdi_debug_register")
Content-Type: multipart/alternative; boundary="94eb2c1affd09f6b320560e3bf92"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@hansenpartnership.com>
Cc: Jens Axboe <axboe@kernel.dk>, Bruno Wolff III <bruno@wolff.to>, Laura Abbott <labbott@redhat.com>, Jan Kara <jack@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "regressions@leemhuis.info" <regressions@leemhuis.info>, weiping zhang <zhangweiping@didichuxing.com>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>

--94eb2c1affd09f6b320560e3bf92
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

2017=E5=B9=B412=E6=9C=8822=E6=97=A5=E6=98=9F=E6=9C=9F=E4=BA=94=EF=BC=8CJame=
s Bottomley <James.Bottomley@hansenpartnership.com> =E5=86=99=E9=81=93=EF=
=BC=9A

> On Thu, 2017-12-21 at 10:02 -0700, Jens Axboe wrote:
> > On 12/21/17 9:42 AM, Bruno Wolff III wrote:
> > >
> > > On Thu, Dec 21, 2017 at 23:48:19 +0800,
> > >   weiping zhang <zwp10758@gmail.com> wrote:
> > > >
> > > > >
> > > > > output you want. I never saw it for any kernels I compiled
> > > > > myself. Only when I test kernels built by Fedora do I see it.
> > > > > see it every boot ?
> > >
> > > I don't look every boot. The warning gets scrolled of the screen.
> > > Once I see the CPU hang warnings I know the boot is failing. I
> > > don't always look at journalctl later to see what's there.
> >
> > I'm going to revert a0747a859ef6 for now, since we're now 8 days into
> > this and no progress has been made on fixing it.
>
> There is a dummy function in this file, if DEBUG_FS =3DN=EF=BC=8C

> I think this is correct.  If you build the kernel with
> CONFIG_DEBUG_FS=3DN, you're definitely going to get the same hang
> (because the debugfs_ functions fail with -ENODEV and the bdi will
> never get registered).  This alone leads me to suspect the commit is
> bogus because it's a randconfig/test accident waiting to happen.
> We should still root cause the debugfs failure in this case, but I
> really think debugfs files should be treated as optional, so a failure
> in setting them up should translate to some sort of warning not a
> failure to set up the bdi.
>
> Yes, its just for debug, has no effect on gendisk(include weiteback),

> James
>
>

--94eb2c1affd09f6b320560e3bf92
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<br><br>2017=E5=B9=B412=E6=9C=8822=E6=97=A5=E6=98=9F=E6=9C=9F=E4=BA=94=EF=
=BC=8CJames Bottomley &lt;<a href=3D"mailto:James.Bottomley@hansenpartnersh=
ip.com">James.Bottomley@hansenpartnership.com</a>&gt; =E5=86=99=E9=81=93=EF=
=BC=9A<br><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;bord=
er-left:1px #ccc solid;padding-left:1ex">On Thu, 2017-12-21 at 10:02 -0700,=
 Jens Axboe wrote:<br>
&gt; On 12/21/17 9:42 AM, Bruno Wolff III wrote:<br>
&gt; &gt;<br>
&gt; &gt; On Thu, Dec 21, 2017 at 23:48:19 +0800,<br>
&gt; &gt; =C2=A0 weiping zhang &lt;<a href=3D"mailto:zwp10758@gmail.com">zw=
p10758@gmail.com</a>&gt; wrote:<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; output you want. I never saw it for any kernels I compi=
led<br>
&gt; &gt; &gt; &gt; myself. Only when I test kernels built by Fedora do I s=
ee it.<br>
&gt; &gt; &gt; &gt; see it every boot ?<br>
&gt; &gt;<br>
&gt; &gt; I don&#39;t look every boot. The warning gets scrolled of the scr=
een.<br>
&gt; &gt; Once I see the CPU hang warnings I know the boot is failing. I<br=
>
&gt; &gt; don&#39;t always look at journalctl later to see what&#39;s there=
.<br>
&gt;<br>
&gt; I&#39;m going to revert a0747a859ef6 for now, since we&#39;re now 8 da=
ys into<br>
&gt; this and no progress has been made on fixing it.<br>
<br></blockquote><div>There is a dummy function in this file, if DEBUG_FS =
=3DN=EF=BC=8C=C2=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:=
0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
I think this is correct.=C2=A0 If you build the kernel with<br>
CONFIG_DEBUG_FS=3DN, you&#39;re definitely going to get the same hang<br>
(because the debugfs_ functions fail with -ENODEV and the bdi will<br>
never get registered).=C2=A0 This alone leads me to suspect the commit is<b=
r>
bogus because it&#39;s a randconfig/test accident waiting to happen.<br>
We should still root cause the debugfs failure in this case, but I<br>
really think debugfs files should be treated as optional, so a failure<br>
in setting them up should translate to some sort of warning not a<br>
failure to set up the bdi.<br>
<br></blockquote><div>Yes, its just for debug, has no effect on gendisk(inc=
lude weiteback),=C2=A0</div><blockquote class=3D"gmail_quote" style=3D"marg=
in:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
James<br>
<br>
</blockquote>

--94eb2c1affd09f6b320560e3bf92--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
