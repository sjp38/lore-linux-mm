Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id B1EBE8D0040
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 16:33:46 -0400 (EDT)
Received: from d01dlp01.pok.ibm.com (d01dlp01.pok.ibm.com [9.56.224.56])
	by e3.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p2VKD1ws010073
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 16:13:01 -0400
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 9035938C803C
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 16:33:37 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p2VKXiIU391940
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 16:33:44 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p2VKXfTW019223
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 16:33:44 -0400
Subject: Re: [PATCH 04/12] mm: alloc_contig_freed_pages() added
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20110331192429.GD14441@home.goodmis.org>
References: <1301577368-16095-1-git-send-email-m.szyprowski@samsung.com>
	 <1301577368-16095-5-git-send-email-m.szyprowski@samsung.com>
	 <1301587083.31087.1032.camel@nimitz>
	 <20110331192429.GD14441@home.goodmis.org>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Thu, 31 Mar 2011 13:33:39 -0700
Message-ID: <1301603619.31087.1203.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-samsung-soc@vger.kernel.org, linux-media@vger.kernel.org, linux-mm@kvack.org, Michal Nazarewicz <mina86@mina86.com>, Kyungmin Park <kyungmin.park@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Johan MOSSBERG <johan.xx.mossberg@stericsson.com>, Mel Gorman <mel@csn.ul.ie>, Pawel Osciak <pawel@osciak.com>

On Thu, 2011-03-31 at 15:24 -0400, Steven Rostedt wrote:
> On Thu, Mar 31, 2011 at 08:58:03AM -0700, Dave Hansen wrote:
> > On Thu, 2011-03-31 at 15:16 +0200, Marek Szyprowski wrote:
> > > 
> > > +unsigned long alloc_contig_freed_pages(unsigned long start, unsigned long end,
> > > +                                      gfp_t flag)
> > > +{
> > > +       unsigned long pfn = start, count;
> > > +       struct page *page;
> > > +       struct zone *zone;
> > > +       int order;
> > > +
> > > +       VM_BUG_ON(!pfn_valid(start));
> > 
> > This seems kinda mean.  Could we return an error?  I understand that
> > this is largely going to be an early-boot thing, but surely trying to
> > punt on crappy input beats a full-on BUG().
> > 
> > 	if (!pfn_valid(start))
> > 		return -1;
> 
> But still keep the warning?
> 
> 	if (WARN_ON(!pfn_valid(start))
> 		return -1;

Sure.  You might also want to make sure you're respecting __GFP_NOWARN
if you're going to do that, or maybe just warn once per boot.


-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
