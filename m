Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id CBABE8D003B
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 01:49:25 -0400 (EDT)
Received: by iyh42 with SMTP id 42so508329iyh.14
        for <linux-mm@kvack.org>; Tue, 19 Apr 2011 22:49:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTinCq22_JckA9XfOjYh3pozUWW1V1Q@mail.gmail.com>
References: <BANLkTinOV=tXcC-XipPzUhs-yODjnOu=8g@mail.gmail.com>
	<BANLkTik_wKoJ43XBPWd4tb9hMds-_7aVCg@mail.gmail.com>
	<BANLkTinCq22_JckA9XfOjYh3pozUWW1V1Q@mail.gmail.com>
Date: Wed, 20 Apr 2011 14:49:23 +0900
Message-ID: <BANLkTimLmOfCruREX8-FW-JVOgmXXbbfWg@mail.gmail.com>
Subject: Re: [HELP] OOM:Page allocation fragment issue
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: TAO HU <tghk48@motorola.com>
Cc: linux-mm@kvack.org, linux-input@vger.kernel.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>

On Wed, Apr 20, 2011 at 2:40 PM, TAO HU <tghk48@motorola.com> wrote:
> Hi, Minchan Kim
>
> Thanks for your analysis and suggestion!
>
> I'm not familiar with COMPACTION.

It's rather recent new feature of mm.

> Does it work with ARM?

Logically, It doesn't depends on architecture.
But I am not sure because ARM's ugly pfn_valid hole in sparsemem.
(I don't remember it well but there was some issue at that time)
I guess if you use FLATMEM, it works well.
If you have a trouble, please report it.

> Does it require specific MMU configuration? Notice that it depends on
> HUGETLB_PAGE
>

It doesn't depends on hugetlb. It is fixed [33a938774fdb: mm:
compaction: don't depend on HUGETLB_PAGE] recently. You can backport
it.

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
