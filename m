Date: Wed, 16 May 2007 09:36:33 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 6/8] Add __GFP_TEMPORARY to identify allocations that
 are short-lived
Message-Id: <20070516093633.c8571b62.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070515150512.16348.58421.sendpatchset@skynet.skynet.ie>
References: <20070515150311.16348.56826.sendpatchset@skynet.skynet.ie>
	<20070515150512.16348.58421.sendpatchset@skynet.skynet.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: clameter@sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 15 May 2007 16:05:12 +0100 (IST)
Mel Gorman <mel@csn.ul.ie> wrote:

> Currently allocations that are short-lived or reclaimable by the kernel are
> grouped together by specifying __GFP_RECLAIMABLE in the GFP flags. However,
> it is confusing when reading code to see a temporary allocation using
> __GFP_RECLAIMABLE when it is clearly not reclaimable.
> 
> This patch adds __GFP_TEMPORARY, GFP_TEMPORARY and SLAB_TEMPORARY for
> temporary allocations. 

What kind of objects should be considered to be TEMPORARY (short-lived) ?
It seems hard-to-use if no documentation.
Could you add clear explanation in header file ?

In my understanding, following case is typical.

==
foo() {
	alloc();
	do some work
	free();
}
==

Other cases ?

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
