Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 52B516B004F
	for <linux-mm@kvack.org>; Tue, 16 Jun 2009 08:29:31 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5GCUNZc028140
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 16 Jun 2009 21:30:24 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5E4FF45DE59
	for <linux-mm@kvack.org>; Tue, 16 Jun 2009 21:30:23 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0EB2345DE56
	for <linux-mm@kvack.org>; Tue, 16 Jun 2009 21:30:23 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id D9D761DB8061
	for <linux-mm@kvack.org>; Tue, 16 Jun 2009 21:30:22 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8AA531DB8040
	for <linux-mm@kvack.org>; Tue, 16 Jun 2009 21:30:22 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 0/3] Fix malloc() stall in zone_reclaim() and bring behaviour more in line with expectations V3
In-Reply-To: <20090616122056.GC14241@csn.ul.ie>
References: <20090616202210.99B2.A69D9226@jp.fujitsu.com> <20090616122056.GC14241@csn.ul.ie>
Message-Id: <20090616212935.99B8.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 16 Jun 2009 21:30:21 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Christoph Lameter <cl@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, riel@redhat.com, fengguang.wu@intel.com, linuxram@us.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

> On Tue, Jun 16, 2009 at 09:08:47PM +0900, KOSAKI Motohiro wrote:
> > > On Mon, Jun 15, 2009 at 11:01:41AM -0400, Christoph Lameter wrote:
> > > > On Mon, 15 Jun 2009, Mel Gorman wrote:
> > > > 
> > > > > > May I ask your worry?
> > > > > >
> > > > >
> > > > > Simply that I believe the intention of PF_SWAPWRITE here was to allow
> > > > > zone_reclaim() to aggressively reclaim memory if the reclaim_mode allowed
> > > > > it as it was a statement that off-node accesses are really not desired.
> > > > 
> > > > Right.
> > > > 
> > > > > Ok. I am not fully convinced but I'll not block it either if believe it's
> > > > > necessary. My current understanding is that this patch only makes a difference
> > > > > if the server is IO congested in which case the system is struggling anyway
> > > > > and an off-node access is going to be relatively small penalty overall.
> > > > > Conceivably, having PF_SWAPWRITE set makes things worse in that situation
> > > > > and the patch makes some sense.
> > > > 
> > > > We could drop support for RECLAIM_SWAP if that simplifies things.
> > > > 
> > > 
> > > I don't think that is necessary. While I expect it's very rarely used, I
> > > imagine a situation where it would be desirable on a system that had large
> > > amounts of tmpfs pages but where it wasn't critical they remain in-memory.
> > > 
> > > Removing PF_SWAPWRITE would make it less aggressive and if you were
> > > happy with that, then that would be good enough for me.
> > 
> > I surprised this a bit. I've imazined Christoph never agree to remove it.
> > Currently, trouble hitting user of mine don't use this feature. Thus, if it can be
> > removed, I don't need to worry abusing this again and I'm happy.
> > 
> > Mel, Have you seen actual user of this?
> > 
> 
> No, but then again the usage for it is quite specific. Namely for use on
> systems that uses a large amount of tmpfs where the remote NUMA penalty is
> high and it's acceptable to swap tmpfs pages to avoid remote accesses. I
> don't see the harm in having the option available.

ok.
I understand your opinion. 

Thanks.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
