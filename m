Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 4B2BE6B0207
	for <linux-mm@kvack.org>; Fri,  2 Apr 2010 02:48:04 -0400 (EDT)
Received: from il06vts02.mot.com (il06vts02.mot.com [129.188.137.142])
	by mdgate1.mot.com (8.14.3/8.14.3) with SMTP id o326mI6u021907
	for <linux-mm@kvack.org>; Fri, 2 Apr 2010 00:48:18 -0600 (MDT)
Received: from mail-gy0-f182.google.com (mail-gy0-f182.google.com [209.85.160.182])
	by mdgate1.mot.com (8.14.3/8.14.3) with ESMTP id o326mHSM021898
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=OK)
	for <linux-mm@kvack.org>; Fri, 2 Apr 2010 00:48:18 -0600 (MDT)
Received: by gyg10 with SMTP id 10so412215gyg.27
        for <linux-mm@kvack.org>; Thu, 01 Apr 2010 23:48:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <o2j28c262361004012213tc9fdebc7yc535f4130a86e644@mail.gmail.com>
References: <i2i5f4a33681003312105m4cd42e9ayfe35cc0988c401b6@mail.gmail.com>
	 <g2g5f4a33681004012051wedea9538w9da89e210b731422@mail.gmail.com>
	 <o2j28c262361004012213tc9fdebc7yc535f4130a86e644@mail.gmail.com>
Date: Fri, 2 Apr 2010 14:48:00 +0800
Message-ID: <y2r5f4a33681004012348q2b613930o6fc3c9d7060d9107@mail.gmail.com>
Subject: Re: [Question] race condition in mm/page_alloc.c regarding page->lru?
From: TAO HU <tghk48@motorola.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Ye Yuan.Bo-A22116" <yuan-bo.ye@motorola.com>, Chang Qing-A21550 <Qing.Chang@motorola.com>, linux-arm-kernel@lists.infradead.org, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Hi, Minchan Kim

It is hard to reproduce the problem.
We only observed it  twice in the past month.
And it randomly occurred a few more times before.

So I'm afraid neither git-bisect nor QEMU-goldfish would help.

On Fri, Apr 2, 2010 at 1:13 PM, Minchan Kim <minchan.kim@gmail.com> wrote:
> On Fri, Apr 2, 2010 at 12:51 PM, TAO HU <tghk48@motorola.com> wrote:
>> 2 patches related to page_alloc.c were applied.
>> Does anyone see a connection between the 2 patches and the panic?
>
> Seem to not related to the problem.
> I don't have seen the problem before.
>
> Could you git-bisect to make sure which patch makes bug?
> Is it reproducible?
> Can I reproduce it in QEMU-goldfish?
>
> --
> Kind regards,
> Minchan Kim
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
