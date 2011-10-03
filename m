Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 75AE99000C6
	for <linux-mm@kvack.org>; Mon,  3 Oct 2011 09:35:19 -0400 (EDT)
Received: by qyl38 with SMTP id 38so2231485qyl.14
        for <linux-mm@kvack.org>; Mon, 03 Oct 2011 06:35:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAMuHMdVuMHjbDkAdrkfTS-ZaYCwN-avihsQyDsOAVFt+PdWqYw@mail.gmail.com>
References: <CADLM8XNiaxLFRZXs4NKJmoORvED-DV0bNxPF6eHsfnLqtxw09w@mail.gmail.com>
	<20111003192458.14d198a3.kamezawa.hiroyu@jp.fujitsu.com>
	<CAMuHMdVuMHjbDkAdrkfTS-ZaYCwN-avihsQyDsOAVFt+PdWqYw@mail.gmail.com>
Date: Mon, 3 Oct 2011 21:35:17 +0800
Message-ID: <CADLM8XP09kFhxjMYbxD80+4cS00cm2aWZE1Zvjoby0Afrdz9eQ@mail.gmail.com>
Subject: Re: One comment on the __release_region in kernel/resource.c
From: Wei Yang <weiyang.kernel@gmail.com>
Content-Type: multipart/alternative; boundary=bcaec5395f1ea7319d04ae650b0c
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

--bcaec5395f1ea7319d04ae650b0c
Content-Type: text/plain; charset=ISO-8859-1

2011/10/3 Geert Uytterhoeven <geert@linux-m68k.org>

> On Mon, Oct 3, 2011 at 12:24, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Sun, 2 Oct 2011 21:57:07 +0800
> > Wei Yang <weiyang.kernel@gmail.com> wrote:
> >
> >> Dear experts,
> >>
> >> I am viewing the source code of __release_region() in kernel/resource.c.
> >> And I have one comment for the performance issue.
> >>
> >> For example, we have a resource tree like this.
> >> 10-89
> >>    20-79
> >>        30-49
> >>        55-59
> >>        60-64
> >>        65-69
> >>    80-89
> >> 100-279
> >>
> >> If the caller wants to release a region of [50,59], the original code
> will
>                                               ^^^^^^^
> Do you really mean [50,59]?
>
Yes.

> I don't think that's allowed, as the tree has [55,59], so you would release
> a
> larger region that allocated.
>
So you mean the case I mentioned will not happen?
Actually, I believe every developer should pass the resource region which
has been allocated.
While if some one made a mistake and pass a region which is not allocated
before and overlap
some "BUSY" region?


>
> Gr{oetje,eeting}s,
>
>                         Geert
>
> --
> Geert Uytterhoeven -- There's lots of Linux beyond ia32 --
> geert@linux-m68k.org
>
> In personal conversations with technical people, I call myself a hacker.
> But
> when I'm talking to journalists I just say "programmer" or something like
> that.
>                                 -- Linus Torvalds
>



-- 
Wei Yang
Help You, Help Me

--bcaec5395f1ea7319d04ae650b0c
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">2011/10/3 Geert Uytterhoeven <span dir=
=3D"ltr">&lt;<a href=3D"mailto:geert@linux-m68k.org">geert@linux-m68k.org</=
a>&gt;</span><br><blockquote class=3D"gmail_quote" style=3D"margin: 0pt 0pt=
 0pt 0.8ex; border-left: 1px solid rgb(204, 204, 204); padding-left: 1ex;">
<div class=3D"im">On Mon, Oct 3, 2011 at 12:24, KAMEZAWA Hiroyuki<br>
&lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fujitsu.com">kamezawa.hiroyu@jp.fu=
jitsu.com</a>&gt; wrote:<br>
&gt; On Sun, 2 Oct 2011 21:57:07 +0800<br>
&gt; Wei Yang &lt;<a href=3D"mailto:weiyang.kernel@gmail.com">weiyang.kerne=
l@gmail.com</a>&gt; wrote:<br>
&gt;<br>
&gt;&gt; Dear experts,<br>
&gt;&gt;<br>
&gt;&gt; I am viewing the source code of __release_region() in kernel/resou=
rce.c.<br>
&gt;&gt; And I have one comment for the performance issue.<br>
&gt;&gt;<br>
&gt;&gt; For example, we have a resource tree like this.<br>
&gt;&gt; 10-89<br>
&gt;&gt; =A0 =A020-79<br>
&gt;&gt; =A0 =A0 =A0 =A030-49<br>
&gt;&gt; =A0 =A0 =A0 =A055-59<br>
&gt;&gt; =A0 =A0 =A0 =A060-64<br>
&gt;&gt; =A0 =A0 =A0 =A065-69<br>
&gt;&gt; =A0 =A080-89<br>
&gt;&gt; 100-279<br>
&gt;&gt;<br>
&gt;&gt; If the caller wants to release a region of [50,59], the original c=
ode will<br>
</div> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0^^^^^^^<br>
Do you really mean [50,59]?<br></blockquote><div>Yes. <br></div><blockquote=
 class=3D"gmail_quote" style=3D"margin: 0pt 0pt 0pt 0.8ex; border-left: 1px=
 solid rgb(204, 204, 204); padding-left: 1ex;">
I don&#39;t think that&#39;s allowed, as the tree has [55,59], so you would=
 release a<br>
larger region that allocated.<br></blockquote><div>So you mean the case I m=
entioned will not happen?<br>Actually, I believe every developer should pas=
s the resource region which has been allocated.<br>While if some one made a=
 mistake and pass a region which is not allocated before and overlap <br>
some &quot;BUSY&quot; region?<br>=A0 <br></div><blockquote class=3D"gmail_q=
uote" style=3D"margin: 0pt 0pt 0pt 0.8ex; border-left: 1px solid rgb(204, 2=
04, 204); padding-left: 1ex;">
<br>
Gr{oetje,eeting}s,<br>
<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 Geert<br>
<font color=3D"#888888"><br>
--<br>
Geert Uytterhoeven -- There&#39;s lots of Linux beyond ia32 -- <a href=3D"m=
ailto:geert@linux-m68k.org">geert@linux-m68k.org</a><br>
<br>
In personal conversations with technical people, I call myself a hacker. Bu=
t<br>
when I&#39;m talking to journalists I just say &quot;programmer&quot; or so=
mething like that.<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=A0 =A0=A0 -- Linus =
Torvalds<br>
</font></blockquote></div><br><br clear=3D"all"><br>-- <br>Wei Yang<br>Help=
 You, Help Me<br><br>

--bcaec5395f1ea7319d04ae650b0c--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
