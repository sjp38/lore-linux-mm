Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 64E7B6B0031
	for <linux-mm@kvack.org>; Sat, 10 Aug 2013 12:47:45 -0400 (EDT)
Received: by mail-ob0-f180.google.com with SMTP id up14so7404580obb.39
        for <linux-mm@kvack.org>; Sat, 10 Aug 2013 09:47:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAMyfujeC_p-2cJteayPnA82wPRvoL2ekDNB6bd38d76v7Gb+6w@mail.gmail.com>
References: <CAMyfujfZayb8_673vkb2hdE9J_w+wPTD4aQ6TsY+aWxb9EzY8A@mail.gmail.com>
 <1376080406-4r7r3uye-mutt-n-horiguchi@ah.jp.nec.com> <CAMyfujeC_p-2cJteayPnA82wPRvoL2ekDNB6bd38d76v7Gb+6w@mail.gmail.com>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Sat, 10 Aug 2013 12:47:24 -0400
Message-ID: <CAHGf_=odM+yTTLvqwEw8MztkFEf_kjxvixDqn3g4hpCed4fEzQ@mail.gmail.com>
Subject: Re: [PATCH 1/1] pagemap: fix buffer overflow in add_page_map()
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yonghua zheng <younghua.zheng@gmail.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, Aug 9, 2013 at 8:49 PM, yonghua zheng <younghua.zheng@gmail.com> wrote:
> Update the patch according to Naoya's comment, I also run
> ./scripts/checkpatch.pl, and it passed ;D.
>
> From 96826b0fdf9ec6d6e16c2c595f371dbb841250f7 Mon Sep 17 00:00:00 2001
> From: Yonghua Zheng <younghua.zheng@gmail.com>
> Date: Mon, 5 Aug 2013 12:12:24 +0800
> Subject: [PATCH 1/1] pagemap: fix buffer overflow in add_to_pagemap()
>
> In struc pagemapread:
>
> struct pagemapread {
>     int pos, len;
>     pagemap_entry_t *buffer;
>     bool v2;
> };
>
> pos is number of PM_ENTRY_BYTES in buffer, but len is the size of buffer,
> it is a mistake to compare pos and len in add_to_pagemap() for checking
> buffer is full or not, and this can lead to buffer overflow and random
> kernel panic issue.
>
> Correct len to be total number of PM_ENTRY_BYTES in buffer.
>
> Signed-off-by: Yonghua Zheng <younghua.zheng@gmail.com>

Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
