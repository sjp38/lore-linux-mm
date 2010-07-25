Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 8BCE86B024D
	for <linux-mm@kvack.org>; Sun, 25 Jul 2010 18:26:29 -0400 (EDT)
Received: by iwn2 with SMTP id 2so2674536iwn.14
        for <linux-mm@kvack.org>; Sun, 25 Jul 2010 15:26:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1A61D8EA6755AF458F06EA669A4EC818013896@JKLMAIL02.ixonos.local>
References: <1A61D8EA6755AF458F06EA669A4EC81801387C@JKLMAIL02.ixonos.local>
	<1A61D8EA6755AF458F06EA669A4EC818013896@JKLMAIL02.ixonos.local>
Date: Mon, 26 Jul 2010 07:26:27 +0900
Message-ID: <AANLkTim9eEcfszuYz0RnPs4K3U_t4z7XdQjsNZpE+kkf@mail.gmail.com>
Subject: Re: [PATCH] Tight check of pfn_valid on sparsemem - v3
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: =?ISO-8859-1?Q?Penttil=E4_Mika?= <mika.penttila@ixonos.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

2010/7/26 Penttil=E4 Mika <mika.penttila@ixonos.com>:
> I don't think this works because if the memmap pages get reused, the corr=
esponding struct page->private could be used by chance in such a way that i=
t has the value of MEMMAP_HOLE. Of course unlikely but possible. And after =
all the whole point of freeing part of the memmap is that it could be reuse=
d.
>

You're absolutely right.
Previous version, I didn't do such as.
In this version, I wanted to remove dependency of page->private and
mem_section to identify hole memmap for using it in FLATMEM of ARM but
make mistake.
I will resend the patch

Thanks for careful review.

> --Mika
>
>
>
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
