Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5F22A6B0005
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 05:13:45 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id i27so294568989qte.3
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 02:13:45 -0700 (PDT)
Received: from mail-qt0-x233.google.com (mail-qt0-x233.google.com. [2607:f8b0:400d:c0d::233])
        by mx.google.com with ESMTPS id z45si1061042qta.27.2016.08.02.02.13.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Aug 2016 02:13:44 -0700 (PDT)
Received: by mail-qt0-x233.google.com with SMTP id w38so119773171qtb.0
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 02:13:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <15aabbf1-4036-cd15-a593-3ebfe429e948@mejor.pl>
References: <2f8a65db-e5a8-75f0-8c08-daa41e1cd3ba@mejor.pl>
 <CAM4kBBLsK99PXaCa8Po3huOyGx+qHTrq3Vgsh+FoqqRaMLv-vQ@mail.gmail.com> <15aabbf1-4036-cd15-a593-3ebfe429e948@mejor.pl>
From: Vitaly Wool <vitaly.wool@konsulko.com>
Date: Tue, 2 Aug 2016 11:13:43 +0200
Message-ID: <CAM4kBBL03Qi=iBo9BHfrxv8OXdpMV1DFccm+C9VF1stCTivnzg@mail.gmail.com>
Subject: Re: Choosing z3fold allocator in zswap gives WARNING: CPU: 0 PID:
 5140 at mm/zswap.c:503 __zswap_pool_current+0x56/0x60
Content-Type: multipart/alternative; boundary=001a113ad73e331e0905391322d2
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?Marcin_Miros=C5=82aw?= <marcin@mejor.pl>
Cc: Linux-MM <linux-mm@kvack.org>

--001a113ad73e331e0905391322d2
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Mon, Aug 1, 2016 at 11:21 AM, Marcin Miros=C5=82aw <marcin@mejor.pl> wro=
te:

> W dniu 01.08.2016 o 11:08, Vitaly Wool pisze:
> > Hi Marcin,
> >
> > Den 1 aug. 2016 11:04 fm skrev "Marcin Miros=C5=82aw" <marcin@mejor.pl
> > <mailto:marcin@mejor.pl>>:
> >>
> >> Hi!
> >> I'm testing kernel-git
> >> (git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
> > <http://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git> , a=
t
> >> 07f00f06ba9a5533d6650d46d3e938f6cbeee97e ) because I noticed strange O=
OM
> >> behavior in kernel 4.7.0. As for now I can't reproduce problems with
> >> OOM, probably it's fixed now.
> >> But now I wanted to try z3fold with zswap. When I did `echo z3fold >
> >> /sys/module/zswap/parameters/zpool` I got trace from dmesg:
> >
> > Could you please give more info on how to reproduce this?
>
> Nothing special. Just rebooted server (vm on kvm), started services and
> issued `echo z3fold > ...`
>

Well, first of all this is Intel right?

~vitaly

--001a113ad73e331e0905391322d2
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_extra"><br><div class=3D"gmail_quo=
te">On Mon, Aug 1, 2016 at 11:21 AM, Marcin Miros=C5=82aw <span dir=3D"ltr"=
>&lt;<a href=3D"mailto:marcin@mejor.pl" target=3D"_blank">marcin@mejor.pl</=
a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"margin:0=
 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">W dniu 01.08.2016 o =
11:08, Vitaly Wool pisze:<br>
<span class=3D"">&gt; Hi Marcin,<br>
&gt;<br>
&gt; Den 1 aug. 2016 11:04 fm skrev &quot;Marcin Miros=C5=82aw&quot; &lt;<a=
 href=3D"mailto:marcin@mejor.pl">marcin@mejor.pl</a><br>
</span>&gt; &lt;mailto:<a href=3D"mailto:marcin@mejor.pl">marcin@mejor.pl</=
a>&gt;&gt;:<br>
<span class=3D"">&gt;&gt;<br>
&gt;&gt; Hi!<br>
&gt;&gt; I&#39;m testing kernel-git<br>
&gt;&gt; (git://<a href=3D"http://git.kernel.org/pub/scm/linux/kernel/git/t=
orvalds/linux.git" rel=3D"noreferrer" target=3D"_blank">git.kernel.org/pub/=
scm/linux/kernel/git/torvalds/linux.git</a><br>
</span>&gt; &lt;<a href=3D"http://git.kernel.org/pub/scm/linux/kernel/git/t=
orvalds/linux.git" rel=3D"noreferrer" target=3D"_blank">http://git.kernel.o=
rg/pub/scm/linux/kernel/git/torvalds/linux.git</a>&gt; , at<br>
<span class=3D"">&gt;&gt; 07f00f06ba9a5533d6650d46d3e938f6cbeee97e ) becaus=
e I noticed strange OOM<br>
&gt;&gt; behavior in kernel 4.7.0. As for now I can&#39;t reproduce problem=
s with<br>
&gt;&gt; OOM, probably it&#39;s fixed now.<br>
&gt;&gt; But now I wanted to try z3fold with zswap. When I did `echo z3fold=
 &gt;<br>
&gt;&gt; /sys/module/zswap/parameters/zpool` I got trace from dmesg:<br>
&gt;<br>
&gt; Could you please give more info on how to reproduce this?<br>
<br>
</span>Nothing special. Just rebooted server (vm on kvm), started services =
and<br>
issued `echo z3fold &gt; ...`<br></blockquote><div><br></div><div>Well, fir=
st of all this is Intel right?</div><div><br></div><div>~vitaly=C2=A0</div>=
</div></div></div>

--001a113ad73e331e0905391322d2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
