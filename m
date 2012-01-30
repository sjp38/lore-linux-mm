Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 6D1A06B004D
	for <linux-mm@kvack.org>; Mon, 30 Jan 2012 08:25:47 -0500 (EST)
Date: Mon, 30 Jan 2012 13:25:43 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 03/15] mm: compaction: introduce
 isolate_migratepages_range().
Message-ID: <20120130132543.GP25268@csn.ul.ie>
References: <1327568457-27734-1-git-send-email-m.szyprowski@samsung.com>
 <1327568457-27734-4-git-send-email-m.szyprowski@samsung.com>
 <20120130112428.GF25268@csn.ul.ie>
 <op.v8wdlovn3l0zgt@mpn-glaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <op.v8wdlovn3l0zgt@mpn-glaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daniel Walker <dwalker@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Gaignard <benjamin.gaignard@linaro.org>

On Mon, Jan 30, 2012 at 01:42:50PM +0100, Michal Nazarewicz wrote:
> >On Thu, Jan 26, 2012 at 10:00:45AM +0100, Marek Szyprowski wrote:
> >>From: Michal Nazarewicz <mina86@mina86.com>
> >>@@ -313,7 +316,7 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
> >> 		} else if (!locked)
> >> 			spin_lock_irq(&zone->lru_lock);
> >>
> >>-		if (!pfn_valid_within(low_pfn))
> >>+		if (!pfn_valid(low_pfn))
> >> 			continue;
> >> 		nr_scanned++;
> >>
> 
> On Mon, 30 Jan 2012 12:24:28 +0100, Mel Gorman <mel@csn.ul.ie> wrote:
> >This chunk looks unrelated to the rest of the patch.
> >
> >I think what you are doing is patching around a bug that CMA exposed
> >which is very similar to the bug report at
> >http://www.spinics.net/lists/linux-mm/msg29260.html . Is this true?
> >
> >If so, I posted a fix that only calls pfn_valid() when necessary. Can
> >you check if that works for you and if so, drop this hunk please? If
> >the patch does not work for you, then this hunk still needs to be
> >in a separate patch and handled separately as it would also be a fix
> >for -stable.
> 
> I'll actually never encountered this bug myself and CMA is unlikely to
> expose it, since it always operates on continuous memory regions with
> no holes.
> 
> I've made this change because looking at the code it seemed like this
> may cause problems in some cases.  The crash that you linked to looks
> like the kind of problem I was thinking about.
> 
> I'll drop this hunk and let you resolve this independently of CMA.
> 

Ok, thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
