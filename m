Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id CC3236B036B
	for <linux-mm@kvack.org>; Wed, 21 Dec 2016 00:08:53 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id n68so127499733itn.4
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 21:08:53 -0800 (PST)
Received: from mail-io0-x244.google.com (mail-io0-x244.google.com. [2607:f8b0:4001:c06::244])
        by mx.google.com with ESMTPS id f25si18676023ioj.155.2016.12.20.21.08.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Dec 2016 21:08:53 -0800 (PST)
Received: by mail-io0-x244.google.com with SMTP id b194so24571204ioa.3
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 21:08:52 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <7fd4b8b0-e305-1c6a-51ea-d5459c77d923@gmail.com>
References: <7fd4b8b0-e305-1c6a-51ea-d5459c77d923@gmail.com>
From: YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>
Date: Wed, 21 Dec 2016 00:08:52 -0500
Message-ID: <CAAR42d==ZF-=dziVSPjzWX5WpHEYsjZRA4xgpqJzDPJjotBc4Q@mail.gmail.com>
Subject: Re: [Patch 0/2] mm/memory_hotplug: fix hot remove bug
Content-Type: multipart/alternative; boundary=001a114abd0221e9b00544242675
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

--001a114abd0221e9b00544242675
Content-Type: text/plain; charset=UTF-8

Self-NACK.
I sent wrong patch-set...

Thanks,
Yasuaki Ishimatsu

2016-12-20 14:15 GMT-05:00 Yasuaki Ishimatsu <yasu.isimatu@gmail.com>:

> Here are two patches for memory hotplug:
>
> Yasuaki Ishimatsu (2):
>   mm/sparse: use page_private() to get page->private value
>   mm/memory_hotplug: set magic number to page->freelsit instead
>     of page->lru.next
>
>  arch/x86/mm/init_64.c | 2 +-
>  mm/memory_hotplug.c   | 4 ++--
>  mm/sparse.c           | 4 ++--
>  3 files changed, 5 insertions(+), 5 deletions(-)
>

--001a114abd0221e9b00544242675
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div>Self-NACK.<br></div>I sent wrong patch-set...<br><div=
><div><div><div><div><div class=3D"gmail_extra"><br></div><div class=3D"gma=
il_extra">Thanks,<br></div><div class=3D"gmail_extra">Yasuaki Ishimatsu<br>=
</div><div class=3D"gmail_extra"><br><div class=3D"gmail_quote">2016-12-20 =
14:15 GMT-05:00 Yasuaki Ishimatsu <span dir=3D"ltr">&lt;<a href=3D"mailto:y=
asu.isimatu@gmail.com" target=3D"_blank">yasu.isimatu@gmail.com</a>&gt;</sp=
an>:<br><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border=
-left:1px #ccc solid;padding-left:1ex">Here are two patches for memory hotp=
lug:<br>
<br>
Yasuaki Ishimatsu (2):<br>
=C2=A0 mm/sparse: use page_private() to get page-&gt;private value<br>
=C2=A0 mm/memory_hotplug: set magic number to page-&gt;freelsit instead<br>
=C2=A0 =C2=A0 of page-&gt;lru.next<br>
<br>
=C2=A0arch/x86/mm/init_64.c | 2 +-<br>
=C2=A0mm/memory_hotplug.c=C2=A0 =C2=A0| 4 ++--<br>
=C2=A0mm/sparse.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| 4 ++--<br>
=C2=A03 files changed, 5 insertions(+), 5 deletions(-)<br>
</blockquote></div><br></div></div></div></div></div></div></div>

--001a114abd0221e9b00544242675--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
