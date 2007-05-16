Date: Tue, 15 May 2007 17:52:27 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 6/8] Add __GFP_TEMPORARY to identify allocations that
 are short-lived
In-Reply-To: <20070516093633.c8571b62.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0705151751240.4272@schroedinger.engr.sgi.com>
References: <20070515150311.16348.56826.sendpatchset@skynet.skynet.ie>
 <20070515150512.16348.58421.sendpatchset@skynet.skynet.ie>
 <20070516093633.c8571b62.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 16 May 2007, KAMEZAWA Hiroyuki wrote:

> What kind of objects should be considered to be TEMPORARY (short-lived) ?
> It seems hard-to-use if no documentation.
> Could you add clear explanation in header file ?
> 
> In my understanding, following case is typical.
> 
> ==
> foo() {
> 	alloc();
> 	do some work
> 	free();
> }
> ==
> 
> Other cases ?

GFP_TEMPORARY means that the memory will be freed in a short time without 
further kernel intervention. I.e. there is no reclaim pass, user 
intervention or other cleanup needed. I think network slabs also fit that 
description.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
