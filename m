Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f45.google.com (mail-oi0-f45.google.com [209.85.218.45])
	by kanga.kvack.org (Postfix) with ESMTP id BB7EA6B006E
	for <linux-mm@kvack.org>; Wed, 28 Jan 2015 20:57:39 -0500 (EST)
Received: by mail-oi0-f45.google.com with SMTP id g201so22250423oib.4
        for <linux-mm@kvack.org>; Wed, 28 Jan 2015 17:57:39 -0800 (PST)
Received: from mail-oi0-x231.google.com (mail-oi0-x231.google.com. [2607:f8b0:4003:c06::231])
        by mx.google.com with ESMTPS id y137si3078078oif.63.2015.01.28.17.57.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 28 Jan 2015 17:57:38 -0800 (PST)
Received: by mail-oi0-f49.google.com with SMTP id a3so22199412oib.8
        for <linux-mm@kvack.org>; Wed, 28 Jan 2015 17:57:38 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150128233343.GC4706@blaptop>
References: <1422432945-6764-1-git-send-email-minchan@kernel.org>
	<1422432945-6764-2-git-send-email-minchan@kernel.org>
	<20150128145651.GB965@swordfish>
	<20150128233343.GC4706@blaptop>
Date: Thu, 29 Jan 2015 10:57:38 +0900
Message-ID: <CAHqPoqKZFDSjO1pL+ixYe_m_L0nGNcu04qSNp-jd1fUixKtHnw@mail.gmail.com>
Subject: Re: [PATCH v1 2/2] zram: remove init_lock in zram_make_request
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Content-Type: multipart/alternative; boundary=001a113cf2b4062ef9050dc0d0ad
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Nitin Gupta <ngupta@vflare.org>, Jerome Marchand <jmarchan@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>, sergey.senozhatsky.work@gmail.com

--001a113cf2b4062ef9050dc0d0ad
Content-Type: text/plain; charset=UTF-8

On Thu, Jan 29, 2015 at 8:33 AM, Minchan Kim <minchan@kernel.org> wrote:

> On Wed, Jan 28, 2015 at 11:56:51PM +0900, Sergey Senozhatsky wrote:
> > I don't like re-introduced ->init_done.
> > another idea... how about using `zram->disksize == 0' instead of
> > `->init_done' (previously `->meta != NULL')? should do the trick.
>
> It could be.
>
>
care to change it?



> >
> >
> > and I'm not sure I get this rmb...
>
> What makes you not sure?
> I think it's clear and common pattern for smp_[wmb|rmb]. :)
>


well... what that "if (ret)" gives? it's almost always true, because the
device is initialized during read/write operations (in 99.99% of cases).

-ss

--001a113cf2b4062ef9050dc0d0ad
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_extra"><br><div class=3D"gmail_quote">=
On Thu, Jan 29, 2015 at 8:33 AM, Minchan Kim <span dir=3D"ltr">&lt;<a href=
=3D"mailto:minchan@kernel.org" target=3D"_blank">minchan@kernel.org</a>&gt;=
</span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .=
8ex;border-left:1px #ccc solid;padding-left:1ex"><div><div>On Wed, Jan 28, =
2015 at 11:56:51PM +0900, Sergey Senozhatsky wrote:<br>&gt; I don&#39;t lik=
e re-introduced -&gt;init_done.<br>
&gt; another idea... how about using `zram-&gt;disksize =3D=3D 0&#39; inste=
ad of<br>
&gt; `-&gt;init_done&#39; (previously `-&gt;meta !=3D NULL&#39;)? should do=
 the trick.<br>
<br>
</div></div>It could be.<br>
<span></span><br></blockquote><div><br>care to change it?<br><br>=C2=A0</di=
v><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:=
1px #ccc solid;padding-left:1ex"><span>
&gt;<br>
&gt;<br>
&gt; and I&#39;m not sure I get this rmb...<br>
<br>
</span>What makes you not sure?<br>
I think it&#39;s clear and common pattern for smp_[wmb|rmb]. :)<br></blockq=
uote><div><br><br>well... what that &quot;if (ret)&quot; gives? it&#39;s al=
most always true, because the<br>device is initialized during read/write op=
erations (in 99.99% of cases).<br><br>-ss</div></div></div></div>

--001a113cf2b4062ef9050dc0d0ad--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
