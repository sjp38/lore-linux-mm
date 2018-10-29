Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 431396B0376
	for <linux-mm@kvack.org>; Mon, 29 Oct 2018 08:27:51 -0400 (EDT)
Received: by mail-lj1-f197.google.com with SMTP id s14-v6so3220593lji.2
        for <linux-mm@kvack.org>; Mon, 29 Oct 2018 05:27:51 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q7-v6sor11560697ljj.17.2018.10.29.05.27.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 Oct 2018 05:27:49 -0700 (PDT)
MIME-Version: 1.0
References: <20181025112821.0924423fb9ecc7918896ec2b@gmail.com> <20181025124249.0ba63f1041ed8836ff6e6190@linux-foundation.org>
In-Reply-To: <20181025124249.0ba63f1041ed8836ff6e6190@linux-foundation.org>
From: Vitaly Wool <vitalywool@gmail.com>
Date: Mon, 29 Oct 2018 13:27:36 +0100
Message-ID: <CAMJBoFMWV-HbymH6D0PYF6EJFoLoheDHCwaQgZiadvd7BZSE2w@mail.gmail.com>
Subject: Re: [PATCH] z3fold: encode object length in the handle
Content-Type: multipart/alternative; boundary="00000000000064cb7905795d32a2"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Oleksiy.Avramchenko@sony.com, Guenter Roeck <linux@roeck-us.net>

--00000000000064cb7905795d32a2
Content-Type: text/plain; charset="UTF-8"

Hi Andrew,

Den tors 25 okt. 2018 kl 21:42 skrev Andrew Morton <
akpm@linux-foundation.org>:

> On Thu, 25 Oct 2018 11:28:21 +0200 Vitaly Wool <vitalywool@gmail.com>
> wrote:
>
> > Reclaim and free can race on an object (which is basically ok) but
> > in order for reclaim to be able to  map "freed" object we need to
> > encode object length in the handle. handle_to_chunks() is thus
> > introduced to extract object length from a handle and use it during
> > mapping of the last object we couldn't correctly map before.
>
> What are the runtime effects of this change?
>

I haven't observed any adverse impact with this change used in zswap (and
in fact, this is a bugfix for zswap operation). There is a slight under 1%
impact when z3fold is used with ZRAM but since the support for ZRAM over
zpool is still out of tree, I take it doesn't matter at this point, right?

Best regards,
   Vitaly

--00000000000064cb7905795d32a2
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Hi Andrew,<br><div><br><div class=3D"gmail_quote"><div dir=
=3D"ltr">Den tors 25 okt. 2018 kl 21:42 skrev Andrew Morton &lt;<a href=3D"=
mailto:akpm@linux-foundation.org">akpm@linux-foundation.org</a>&gt;:<br></d=
iv><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left=
:1px #ccc solid;padding-left:1ex">On Thu, 25 Oct 2018 11:28:21 +0200 Vitaly=
 Wool &lt;<a href=3D"mailto:vitalywool@gmail.com" target=3D"_blank">vitalyw=
ool@gmail.com</a>&gt; wrote:<br>
<br>
&gt; Reclaim and free can race on an object (which is basically ok) but<br>
&gt; in order for reclaim to be able to=C2=A0 map &quot;freed&quot; object =
we need to<br>
&gt; encode object length in the handle. handle_to_chunks() is thus<br>
&gt; introduced to extract object length from a handle and use it during<br=
>
&gt; mapping of the last object we couldn&#39;t correctly map before.<br>
<br>
What are the runtime effects of this change?<br></blockquote><div><br></div=
><div>I haven&#39;t observed any adverse impact with this change used in zs=
wap (and in fact, this is a bugfix for zswap operation). There is a slight =
under 1% impact when z3fold is used with ZRAM but since the support for ZRA=
M over zpool is still out of tree, I take it doesn&#39;t matter at this poi=
nt, right?</div><div><br></div><div>Best regards,</div><div>=C2=A0=C2=A0 Vi=
taly<br></div></div></div></div>

--00000000000064cb7905795d32a2--
