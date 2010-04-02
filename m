Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 3175C6B01F3
	for <linux-mm@kvack.org>; Fri,  2 Apr 2010 01:13:15 -0400 (EDT)
Received: by pzk2 with SMTP id 2so201797pzk.28
        for <linux-mm@kvack.org>; Thu, 01 Apr 2010 22:13:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <g2g5f4a33681004012051wedea9538w9da89e210b731422@mail.gmail.com>
References: <i2i5f4a33681003312105m4cd42e9ayfe35cc0988c401b6@mail.gmail.com>
	 <g2g5f4a33681004012051wedea9538w9da89e210b731422@mail.gmail.com>
Date: Fri, 2 Apr 2010 14:13:09 +0900
Message-ID: <o2j28c262361004012213tc9fdebc7yc535f4130a86e644@mail.gmail.com>
Subject: Re: [Question] race condition in mm/page_alloc.c regarding page->lru?
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: TAO HU <tghk48@motorola.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Ye Yuan.Bo-A22116" <yuan-bo.ye@motorola.com>, Chang Qing-A21550 <Qing.Chang@motorola.com>, linux-arm-kernel@lists.infradead.org, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Fri, Apr 2, 2010 at 12:51 PM, TAO HU <tghk48@motorola.com> wrote:
> 2 patches related to page_alloc.c were applied.
> Does anyone see a connection between the 2 patches and the panic?

Seem to not related to the problem.
I don't have seen the problem before.

Could you git-bisect to make sure which patch makes bug?
Is it reproducible?
Can I reproduce it in QEMU-goldfish?

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
