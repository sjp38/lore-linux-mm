Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 67CC7900149
	for <linux-mm@kvack.org>; Tue,  4 Oct 2011 10:17:37 -0400 (EDT)
Received: by qyk27 with SMTP id 27so513685qyk.14
        for <linux-mm@kvack.org>; Tue, 04 Oct 2011 07:17:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAMuHMdV_aKGscAw1UmQU45VZONtdvYLTK18nTYX4wvg0YLTx4A@mail.gmail.com>
References: <CADLM8XNiaxLFRZXs4NKJmoORvED-DV0bNxPF6eHsfnLqtxw09w@mail.gmail.com>
	<20111003192458.14d198a3.kamezawa.hiroyu@jp.fujitsu.com>
	<CAMuHMdVuMHjbDkAdrkfTS-ZaYCwN-avihsQyDsOAVFt+PdWqYw@mail.gmail.com>
	<CADLM8XP09kFhxjMYbxD80+4cS00cm2aWZE1Zvjoby0Afrdz9eQ@mail.gmail.com>
	<CAMuHMdV_aKGscAw1UmQU45VZONtdvYLTK18nTYX4wvg0YLTx4A@mail.gmail.com>
Date: Tue, 4 Oct 2011 22:17:33 +0800
Message-ID: <CADLM8XNRCctuUYXDOEXfTU5zYct2CRwy4nxce2pr4ddJ3mfTwQ@mail.gmail.com>
Subject: Re: One comment on the __release_region in kernel/resource.c
From: Wei Yang <weiyang.kernel@gmail.com>
Content-Type: multipart/alternative; boundary=bcaec5395f1eaff21404ae79c063
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

--bcaec5395f1eaff21404ae79c063
Content-Type: text/plain; charset=ISO-8859-1

2011/10/3 Geert Uytterhoeven <geert@linux-m68k.org>

> On Mon, Oct 3, 2011 at 15:35, Wei Yang <weiyang.kernel@gmail.com> wrote:
> > 2011/10/3 Geert Uytterhoeven <geert@linux-m68k.org>
> >> On Mon, Oct 3, 2011 at 12:24, KAMEZAWA Hiroyuki
> >> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> >> > On Sun, 2 Oct 2011 21:57:07 +0800
> >> > Wei Yang <weiyang.kernel@gmail.com> wrote:
> >> >
> >> >> Dear experts,
> >> >>
> >> >> I am viewing the source code of __release_region() in
> >> >> kernel/resource.c.
> >> >> And I have one comment for the performance issue.
> >> >>
> >> >> For example, we have a resource tree like this.
> >> >> 10-89
> >> >>    20-79
> >> >>        30-49
> >> >>        55-59
> >> >>        60-64
> >> >>        65-69
> >> >>    80-89
> >> >> 100-279
> >> >>
> >> >> If the caller wants to release a region of [50,59], the original code
> >> >> will
> >>                                              ^^^^^^^
> >> Do you really mean [50,59]?
> >
> > Yes.
> >>
> >> I don't think that's allowed, as the tree has [55,59], so you would
> >> release a
> >> larger region that allocated.
> >
> > So you mean the case I mentioned will not happen?
>
> Indeed, it should not happen.
> Actually I'm surprised it doesn't return an error code.
>
Do you think someone will take care of this?

>
> > Actually, I believe every developer should pass the resource region which
> > has been allocated.
> > While if some one made a mistake and pass a region which is not allocated
> > before and overlap
> > some "BUSY" region?
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

--bcaec5395f1eaff21404ae79c063
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<br><br><div class=3D"gmail_quote">2011/10/3 Geert Uytterhoeven <span dir=
=3D"ltr">&lt;<a href=3D"mailto:geert@linux-m68k.org">geert@linux-m68k.org</=
a>&gt;</span><br><blockquote class=3D"gmail_quote" style=3D"margin: 0pt 0pt=
 0pt 0.8ex; border-left: 1px solid rgb(204, 204, 204); padding-left: 1ex;">
<div><div></div><div class=3D"h5">On Mon, Oct 3, 2011 at 15:35, Wei Yang &l=
t;<a href=3D"mailto:weiyang.kernel@gmail.com">weiyang.kernel@gmail.com</a>&=
gt; wrote:<br>
&gt; 2011/10/3 Geert Uytterhoeven &lt;<a href=3D"mailto:geert@linux-m68k.or=
g">geert@linux-m68k.org</a>&gt;<br>
&gt;&gt; On Mon, Oct 3, 2011 at 12:24, KAMEZAWA Hiroyuki<br>
&gt;&gt; &lt;<a href=3D"mailto:kamezawa.hiroyu@jp.fujitsu.com">kamezawa.hir=
oyu@jp.fujitsu.com</a>&gt; wrote:<br>
&gt;&gt; &gt; On Sun, 2 Oct 2011 21:57:07 +0800<br>
&gt;&gt; &gt; Wei Yang &lt;<a href=3D"mailto:weiyang.kernel@gmail.com">weiy=
ang.kernel@gmail.com</a>&gt; wrote:<br>
&gt;&gt; &gt;<br>
&gt;&gt; &gt;&gt; Dear experts,<br>
&gt;&gt; &gt;&gt;<br>
&gt;&gt; &gt;&gt; I am viewing the source code of __release_region() in<br>
&gt;&gt; &gt;&gt; kernel/resource.c.<br>
&gt;&gt; &gt;&gt; And I have one comment for the performance issue.<br>
&gt;&gt; &gt;&gt;<br>
&gt;&gt; &gt;&gt; For example, we have a resource tree like this.<br>
&gt;&gt; &gt;&gt; 10-89<br>
&gt;&gt; &gt;&gt; =A0 =A020-79<br>
&gt;&gt; &gt;&gt; =A0 =A0 =A0 =A030-49<br>
&gt;&gt; &gt;&gt; =A0 =A0 =A0 =A055-59<br>
&gt;&gt; &gt;&gt; =A0 =A0 =A0 =A060-64<br>
&gt;&gt; &gt;&gt; =A0 =A0 =A0 =A065-69<br>
&gt;&gt; &gt;&gt; =A0 =A080-89<br>
&gt;&gt; &gt;&gt; 100-279<br>
&gt;&gt; &gt;&gt;<br>
&gt;&gt; &gt;&gt; If the caller wants to release a region of [50,59], the o=
riginal code<br>
&gt;&gt; &gt;&gt; will<br>
&gt;&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0^^^^^^^<br>
&gt;&gt; Do you really mean [50,59]?<br>
&gt;<br>
&gt; Yes.<br>
&gt;&gt;<br>
&gt;&gt; I don&#39;t think that&#39;s allowed, as the tree has [55,59], so =
you would<br>
&gt;&gt; release a<br>
&gt;&gt; larger region that allocated.<br>
&gt;<br>
&gt; So you mean the case I mentioned will not happen?<br>
<br>
</div></div>Indeed, it should not happen.<br>
Actually I&#39;m surprised it doesn&#39;t return an error code.<br></blockq=
uote><div>Do you think someone will take care of this? <br></div><blockquot=
e class=3D"gmail_quote" style=3D"margin: 0pt 0pt 0pt 0.8ex; border-left: 1p=
x solid rgb(204, 204, 204); padding-left: 1ex;">

<div><div></div><div class=3D"h5"><br>
&gt; Actually, I believe every developer should pass the resource region wh=
ich<br>
&gt; has been allocated.<br>
&gt; While if some one made a mistake and pass a region which is not alloca=
ted<br>
&gt; before and overlap<br>
&gt; some &quot;BUSY&quot; region?<br>
<br>
Gr{oetje,eeting}s,<br>
<br>
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 Geert<br>
<br>
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
</div></div></blockquote></div><br><br clear=3D"all"><br>-- <br>Wei Yang<br=
>Help You, Help Me<br><br>

--bcaec5395f1eaff21404ae79c063--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
