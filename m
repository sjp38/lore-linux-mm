Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id AC57E6B006C
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 10:41:21 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id a12so2075996eaa.14
        for <linux-mm@kvack.org>; Tue, 20 Nov 2012 07:41:20 -0800 (PST)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH] mm: cma: allocate pages from CMA if NR_FREE_PAGES approaches low water mark
In-Reply-To: <50AB987F.30002@samsung.com>
References: <1352710782-25425-1-git-send-email-m.szyprowski@samsung.com> <20121120000137.GC447@bbox> <50AB987F.30002@samsung.com>
Date: Tue, 20 Nov 2012 16:41:12 +0100
Message-ID: <xa1tk3tgjn8n.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>, Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, linux-kernel@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Tue, Nov 20 2012, Marek Szyprowski wrote:
> Right now running out of 'plain' movable pages is the only possibility to
> get movable pages allocated from CMA. On the other hand running out of
> 'plain' movable pages is very deadly for the system, as movable pageblocks
> are also the main fallbacks for reclaimable and non-movable pages.
>
> Then, once we run out of movable pages and kernel needs non-mobable or
> reclaimable page (what happens quite often), it usually triggers OOM to
> satisfy the memory needs. Such OOM is very strange, especially on a system
> with dozen of megabytes of CMA memory, having most of them free at the OOM
> event. By high memory pressure I mean the high memory usage.

Would it make sense to *always* use MIGRATE_CMA for movable allocations
before MIGRATE_MOVABLE?  Ie. how about this patch (not tested):

------------------------- >8 ----------------------------------------------=
---
--=-=-=--
