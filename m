Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id BF75B6B009E
	for <linux-mm@kvack.org>; Wed, 10 Jun 2009 02:42:46 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5A6i5UF017652
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 10 Jun 2009 15:44:05 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0BD1645DD72
	for <linux-mm@kvack.org>; Wed, 10 Jun 2009 15:44:05 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id C990645DE50
	for <linux-mm@kvack.org>; Wed, 10 Jun 2009 15:44:04 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id B5D501DB8043
	for <linux-mm@kvack.org>; Wed, 10 Jun 2009 15:44:04 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 489331DB8044
	for <linux-mm@kvack.org>; Wed, 10 Jun 2009 15:44:04 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/3] Reintroduce zone_reclaim_interval for when zone_reclaim() scans and fails to avoid CPU spinning at 100% on NUMA
In-Reply-To: <20090609222301.8da002ae.akpm@linux-foundation.org>
References: <20090608151151.GI15070@csn.ul.ie> <20090609222301.8da002ae.akpm@linux-foundation.org>
Message-Id: <20090610154016.DDC3.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 10 Jun 2009 15:44:03 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux-foundation.org>, Rik van Riel <riel@redhat.com>, yanmin.zhang@intel.com, Wu Fengguang <fengguang.wu@intel.com>, linuxram@us.ibm.com, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi

> On Mon, 8 Jun 2009 16:11:51 +0100 Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > On Mon, Jun 08, 2009 at 10:55:55AM -0400, Christoph Lameter wrote:
> > > On Mon, 8 Jun 2009, Mel Gorman wrote:
> > > 
> > > > > The tmpfs pages are unreclaimable and therefore should not be on the anon
> > > > > lru.
> > > > >
> > > >
> > > > tmpfs pages can be swap-backed so can be reclaimable. Regardless of what
> > > > list they are on, we still need to know how many of them there are if
> > > > this patch is to be avoided.
> > > 
> > > If they are reclaimable then why does it matter? They can be pushed out if
> > > you configure zone reclaim to be that aggressive.
> > > 
> > 
> > Because they are reclaimable by kswapd or normal direct reclaim but *not*
> > reclaimable by zone_reclaim() if the zone_reclaim_mode is not configured
> > appropriately.
> 
> Ah.  (zone_reclaim_mode & RECLAIM_SWAP) == 0.  That was important info.
> 
> Couldn't the lack of RECLAIM_WRITE cause a similar problem?

Old kernel can makes easily. but currenly we have proper dirty page limit.
Thus all pages can't become dirty and zone-reclaim can found cleaner page.

In the other hand, plenty tmpfs pages can be mede easily.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
