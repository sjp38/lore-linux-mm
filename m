Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id A08366B003D
	for <linux-mm@kvack.org>; Wed, 18 Mar 2009 15:12:26 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id A688982D643
	for <linux-mm@kvack.org>; Wed, 18 Mar 2009 15:19:20 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id N5Sb6vvtcY53 for <linux-mm@kvack.org>;
	Wed, 18 Mar 2009 15:19:20 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 7A5AD82D642
	for <linux-mm@kvack.org>; Wed, 18 Mar 2009 15:19:13 -0400 (EDT)
Date: Wed, 18 Mar 2009 15:10:19 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 20/35] Use a pre-calculated value for
 num_online_nodes()
In-Reply-To: <20090318180152.GB24462@csn.ul.ie>
Message-ID: <alpine.DEB.1.10.0903181508030.10154@qirst.com>
References: <1237196790-7268-1-git-send-email-mel@csn.ul.ie> <1237196790-7268-21-git-send-email-mel@csn.ul.ie> <alpine.DEB.1.10.0903161207500.32577@qirst.com> <20090316163626.GJ24293@csn.ul.ie> <alpine.DEB.1.10.0903161247170.17730@qirst.com>
 <20090318150833.GC4629@csn.ul.ie> <alpine.DEB.1.10.0903181256440.15570@qirst.com> <20090318180152.GB24462@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Wed, 18 Mar 2009, Mel Gorman wrote:

> On Wed, Mar 18, 2009 at 12:58:02PM -0400, Christoph Lameter wrote:
> > On Wed, 18 Mar 2009, Mel Gorman wrote:
> >
> > > Naming has never been great, but in this case the static value is a
> > > direct replacement of num_online_nodes(). I think having a
> > > similarly-named-but-still-different name obscures more than it helps.
> >
> > Creates a weird new name. Please use nr_online_nodes. Its useful elsewhere
> > too.
> >
>
> Ok, I'm dropping this patch for the first pass altogether and will deal
> with it later.

This is important infrastructure stuff. num_online_nodes is used in a
couple of other places where it could be replaced by nr_online_nodes.

7 grufile.c     gru_get_config_info          181 if (num_online_nodes() > 1 &&
8 grufile.c     gru_get_config_info          187 info.nodes = num_online_nodes();
9 hugetlb.c     return_unused_surplus_pages  878 unsigned long remaining_iterations = num_online_nodes();
a hugetlb.c     return_unused_surplus_pages  907 remaining_iterations = num_online_nodes();
b page_alloc.c  MAX_NODE_LOAD               2115 #define MAX_NODE_LOAD (num_online_nodes())
c page_alloc.c  build_zonelists             2324 load = num_online_nodes();
d page_alloc.c  build_all_zonelists         2475 num_online_nodes(),
e slub.c        list_locations              3651 if (num_online_nodes() > 1 && !nodes_empty(l->nodes) &&
f svc.c         svc_pool_map_choose_mode     127 if (num_online_nodes() > 1) {

In other places its avoided because deemed to be too expensive.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
