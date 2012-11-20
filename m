Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 32B7D6B0044
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 14:52:24 -0500 (EST)
Date: Tue, 20 Nov 2012 11:52:22 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: dmapool: use provided gfp flags for all
 dma_alloc_coherent() calls
Message-Id: <20121120115222.9b674d86.akpm@linux-foundation.org>
In-Reply-To: <50AB600C.5010801@samsung.com>
References: <1352356737-14413-1-git-send-email-m.szyprowski@samsung.com>
	<20121119001846.GB22106@titan.lakedaemon.net>
	<20121119144826.f59667b2.akpm@linux-foundation.org>
	<50AB600C.5010801@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Jason Cooper <jason@lakedaemon.net>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, Andrew Lunn <andrew@lunn.ch>, Arnd Bergmann <arnd@arndb.de>, Kyungmin Park <kyungmin.park@samsung.com>, Soren Moch <smoch@web.de>, Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>

On Tue, 20 Nov 2012 11:48:44 +0100
Marek Szyprowski <m.szyprowski@samsung.com> wrote:

> > As this patch is already in -next and is stuck there for two more
> > weeks I can't (or at least won't) merge this patch, so I can't help
> > with any of the above.
> 
> I will fix both issues in the next version of the patch. Would like to
> merge it to your tree or should I keep it in my dma-mapping tree?

The patch looks OK to me now (still wondering about the -stable
question though).

It would be a bit of a pain for me to carry a patch which conflicts
with one in linux-next, and this patch doesn't appear to conflict with
the other pending dmapool.c patches in -mm so you may as well keep it
in the dma-mapping tree now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
