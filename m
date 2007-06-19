Date: Tue, 19 Jun 2007 21:54:47 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: [PATCH 5/7] Introduce a means of compacting memory within a zone
In-Reply-To: <20070618093002.7790.68471.sendpatchset@skynet.skynet.ie>
References: <20070618092821.7790.52015.sendpatchset@skynet.skynet.ie> <20070618093002.7790.68471.sendpatchset@skynet.skynet.ie>
Message-Id: <20070619213927.AC83.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

Hi Mel-san.
This is very interesting feature.

Now, I'm testing your patches.

> +static int isolate_migratepages(struct zone *zone,
> +					struct compact_control *cc)
> +{
> +	unsigned long high_pfn, low_pfn, end_pfn, start_pfn;

(snip)

> +	/* Time to isolate some pages for migration */
> +	spin_lock_irq(&zone->lru_lock);
> +	for (; low_pfn < end_pfn; low_pfn++) {
> +		if (!pfn_valid_within(low_pfn))
> +			continue;
> +
> +		/* Get the page and skip if free */
> +		page = pfn_to_page(low_pfn);

I met panic at here on my tiger4.

I compiled with CONFIG_SPARSEMEM. So, CONFIG_HOLES_IN_ZONE is not set.
pfn_valid_within() returns 1 every time on this configuration.
(This config is for only virtual memmap)
But, my tiger4 box has memory holes in normal zone.

When it is changed to normal pfn_valid(), no panic occurs.

Hmmm.

Bye.
-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
