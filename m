Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id E86518D0040
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 15:25:33 -0400 (EDT)
Date: Thu, 31 Mar 2011 15:24:30 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 04/12] mm: alloc_contig_freed_pages() added
Message-ID: <20110331192429.GD14441@home.goodmis.org>
References: <1301577368-16095-1-git-send-email-m.szyprowski@samsung.com>
 <1301577368-16095-5-git-send-email-m.szyprowski@samsung.com>
 <1301587083.31087.1032.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1301587083.31087.1032.camel@nimitz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-samsung-soc@vger.kernel.org, linux-media@vger.kernel.org, linux-mm@kvack.org, Michal Nazarewicz <mina86@mina86.com>, Kyungmin Park <kyungmin.park@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Johan MOSSBERG <johan.xx.mossberg@stericsson.com>, Mel Gorman <mel@csn.ul.ie>, Pawel Osciak <pawel@osciak.com>

On Thu, Mar 31, 2011 at 08:58:03AM -0700, Dave Hansen wrote:
> On Thu, 2011-03-31 at 15:16 +0200, Marek Szyprowski wrote:
> > 
> > +unsigned long alloc_contig_freed_pages(unsigned long start, unsigned long end,
> > +                                      gfp_t flag)
> > +{
> > +       unsigned long pfn = start, count;
> > +       struct page *page;
> > +       struct zone *zone;
> > +       int order;
> > +
> > +       VM_BUG_ON(!pfn_valid(start));
> 
> This seems kinda mean.  Could we return an error?  I understand that
> this is largely going to be an early-boot thing, but surely trying to
> punt on crappy input beats a full-on BUG().
> 
> 	if (!pfn_valid(start))
> 		return -1;

But still keep the warning?

	if (WARN_ON(!pfn_valid(start))
		return -1;

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
