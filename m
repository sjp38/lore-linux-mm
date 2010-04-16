Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 028FD6B0206
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 12:24:19 -0400 (EDT)
Date: Fri, 16 Apr 2010 11:20:32 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] code clean rename alloc_pages_exact_node()
In-Reply-To: <20100413082712.GR25756@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.1004161117360.7710@router.home>
References: <1270900173-10695-1-git-send-email-lliubbo@gmail.com> <20100412164335.GQ25756@csn.ul.ie> <i2l28c262361004122134of7f96809va209e779ccd44195@mail.gmail.com> <20100413144037.f714fdeb.kamezawa.hiroyu@jp.fujitsu.com> <v2qcf18f8341004130009o49bd230cga838b416a75f61e8@mail.gmail.com>
 <20100413082712.GR25756@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Bob Liu <lliubbo@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, kosaki.motohiro@jp.fujitsu.com, penberg@cs.helsinki.fi, lethal@linux-sh.org, a.p.zijlstra@chello.nl, nickpiggin@yahoo.com.au, dave@linux.vnet.ibm.com, lee.schermerhorn@hp.com, rientjes@google.com
List-ID: <linux-mm.kvack.org>

On Tue, 13 Apr 2010, Mel Gorman wrote:

> This appears to be a valid bug fix.  I agree that the way things are structured
> that __GFP_THISNODE should be used in new_node_page(). But maybe a follow-on
> patch is also required. The behaviour is now;

What bug is being fixed? migrate_pages() is a best effort approach.
__GFP_THISNODE is used when allocation on a specific node is absolutely
required for correctness (as in SLAB).

> If -ENOMEM is returned from migrate_pages, should it not move to the next node?

Which it does now if you dont apply the "bugfix".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
