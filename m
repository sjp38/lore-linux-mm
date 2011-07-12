Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4FE226B007E
	for <linux-mm@kvack.org>; Mon, 11 Jul 2011 20:16:12 -0400 (EDT)
Received: by qyk32 with SMTP id 32so2061305qyk.14
        for <linux-mm@kvack.org>; Mon, 11 Jul 2011 17:16:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1107111550430.29346@ubuntu>
References: <CAGtzr3fm2=UJFRo2xSYhst0P4jCMT-EPjyPi3=icCrMtW0ij8w@mail.gmail.com>
	<CAEwNFnB8VXkTiMzJewtd7rSZ8keqkboNz-BBjw_UudquvsrK1A@mail.gmail.com>
	<alpine.DEB.2.00.1107081021040.29346@ubuntu>
	<CAEwNFnCsjRkauM5XvOqh1hLNOT3Hwu2m9pPqO+mCHq7rKLu0Gg@mail.gmail.com>
	<alpine.DEB.2.00.1107111550430.29346@ubuntu>
Date: Tue, 12 Jul 2011 09:16:09 +0900
Message-ID: <CAEwNFnCfsGn1qZbgXNNETFtZAzOSvxpJDcftNcuuSBDXUnxtmA@mail.gmail.com>
Subject: Re: NULL poniter dereference in isolate_lru_pages 2.6.39.1
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Pearson <pearson.christopher.j@gmail.com>
Cc: linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, stable <stable@kernel.org>

On Tue, Jul 12, 2011 at 5:52 AM, Chris Pearson
<pearson.christopher.j@gmail.com> wrote:
> We applied the patch to many servers. =C2=A0No problems so far.
>
> The .config is attached.

Thanks. I verified. The point where isolate_lru_pages + 0x225 is
page_count exactly. So Andrea patch solves this problem apparently.
Couldn't we throw this patch to stable tree?

https://patchwork.kernel.org/patch/857442/

>
> What's the config option to get that debugging info in the future?

CONFIG_DEBUG_INFO helps you. :)

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
