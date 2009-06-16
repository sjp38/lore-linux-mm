Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 2E7B56B004F
	for <linux-mm@kvack.org>; Tue, 16 Jun 2009 08:08:37 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5GC8muh030056
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 16 Jun 2009 21:08:49 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 90CB245DE62
	for <linux-mm@kvack.org>; Tue, 16 Jun 2009 21:08:48 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6496445DE55
	for <linux-mm@kvack.org>; Tue, 16 Jun 2009 21:08:48 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2ABD6E08007
	for <linux-mm@kvack.org>; Tue, 16 Jun 2009 21:08:48 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C94A01DB803F
	for <linux-mm@kvack.org>; Tue, 16 Jun 2009 21:08:47 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 0/3] Fix malloc() stall in zone_reclaim() and bring behaviour more in line with expectations V3
In-Reply-To: <20090615152543.GF23198@csn.ul.ie>
References: <alpine.DEB.1.10.0906151057270.23995@gentwo.org> <20090615152543.GF23198@csn.ul.ie>
Message-Id: <20090616202210.99B2.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 16 Jun 2009 21:08:47 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Christoph Lameter <cl@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, riel@redhat.com, fengguang.wu@intel.com, linuxram@us.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

> On Mon, Jun 15, 2009 at 11:01:41AM -0400, Christoph Lameter wrote:
> > On Mon, 15 Jun 2009, Mel Gorman wrote:
> > 
> > > > May I ask your worry?
> > > >
> > >
> > > Simply that I believe the intention of PF_SWAPWRITE here was to allow
> > > zone_reclaim() to aggressively reclaim memory if the reclaim_mode allowed
> > > it as it was a statement that off-node accesses are really not desired.
> > 
> > Right.
> > 
> > > Ok. I am not fully convinced but I'll not block it either if believe it's
> > > necessary. My current understanding is that this patch only makes a difference
> > > if the server is IO congested in which case the system is struggling anyway
> > > and an off-node access is going to be relatively small penalty overall.
> > > Conceivably, having PF_SWAPWRITE set makes things worse in that situation
> > > and the patch makes some sense.
> > 
> > We could drop support for RECLAIM_SWAP if that simplifies things.
> > 
> 
> I don't think that is necessary. While I expect it's very rarely used, I
> imagine a situation where it would be desirable on a system that had large
> amounts of tmpfs pages but where it wasn't critical they remain in-memory.
> 
> Removing PF_SWAPWRITE would make it less aggressive and if you were
> happy with that, then that would be good enough for me.

I surprised this a bit. I've imazined Christoph never agree to remove it.
Currently, trouble hitting user of mine don't use this feature. Thus, if it can be
removed, I don't need to worry abusing this again and I'm happy.

Mel, Have you seen actual user of this?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
