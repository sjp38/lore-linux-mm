Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 691BF6B004A
	for <linux-mm@kvack.org>; Sun, 10 Jul 2011 19:05:17 -0400 (EDT)
Received: by qwa26 with SMTP id 26so2298543qwa.14
        for <linux-mm@kvack.org>; Sun, 10 Jul 2011 16:05:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1107081021040.29346@ubuntu>
References: <CAGtzr3fm2=UJFRo2xSYhst0P4jCMT-EPjyPi3=icCrMtW0ij8w@mail.gmail.com>
	<CAEwNFnB8VXkTiMzJewtd7rSZ8keqkboNz-BBjw_UudquvsrK1A@mail.gmail.com>
	<alpine.DEB.2.00.1107081021040.29346@ubuntu>
Date: Mon, 11 Jul 2011 08:05:15 +0900
Message-ID: <CAEwNFnCsjRkauM5XvOqh1hLNOT3Hwu2m9pPqO+mCHq7rKLu0Gg@mail.gmail.com>
Subject: Re: NULL poniter dereference in isolate_lru_pages 2.6.39.1
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Pearson <pearson.christopher.j@gmail.com>
Cc: linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>

On Sat, Jul 9, 2011 at 12:39 AM, Chris Pearson
<pearson.christopher.j@gmail.com> wrote:
> addr1line says vmscan.c:0
>
> I must have not compiled with some debugging info?

It seems.

1. Could you post your config?
2. Could you apply/test patch I mentioned?

Thanks.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
