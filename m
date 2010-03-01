Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id AE56D6B0047
	for <linux-mm@kvack.org>; Sun, 28 Feb 2010 21:03:12 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2123AqZ002366
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 1 Mar 2010 11:03:10 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5ACA345DE83
	for <linux-mm@kvack.org>; Mon,  1 Mar 2010 11:03:09 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id BF4AC45DE7B
	for <linux-mm@kvack.org>; Mon,  1 Mar 2010 11:03:08 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7FE66E18009
	for <linux-mm@kvack.org>; Mon,  1 Mar 2010 11:03:08 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 923EF1DB803F
	for <linux-mm@kvack.org>; Mon,  1 Mar 2010 11:03:07 +0900 (JST)
Date: Mon, 1 Mar 2010 10:59:32 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] [4/4] SLAB: Fix node add timer race in cache_reap
Message-Id: <20100301105932.5db60c93.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100226173115.GG16335@basil.fritz.box>
References: <alpine.DEB.2.00.1002191222320.26567@router.home>
	<20100220090154.GB11287@basil.fritz.box>
	<alpine.DEB.2.00.1002240949140.26771@router.home>
	<4B862623.5090608@cs.helsinki.fi>
	<alpine.DEB.2.00.1002242357450.26099@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1002251228140.18861@router.home>
	<20100226114136.GA16335@basil.fritz.box>
	<alpine.DEB.2.00.1002260904311.6641@router.home>
	<20100226155755.GE16335@basil.fritz.box>
	<alpine.DEB.2.00.1002261123520.7719@router.home>
	<20100226173115.GG16335@basil.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haicheng.li@intel.com
List-ID: <linux-mm.kvack.org>

On Fri, 26 Feb 2010 18:31:15 +0100
Andi Kleen <andi@firstfloor.org> wrote:

> On Fri, Feb 26, 2010 at 11:24:50AM -0600, Christoph Lameter wrote:
> > On Fri, 26 Feb 2010, Andi Kleen wrote:
> > 
> > > > > Memory hotplug with node add never quite worked on x86 before,
> > > > > for various reasons not related to slab.
> > > >
> > > > Ok but why did things break in such a big way?
> > >
> > > 1) numa memory hotadd never worked
> > 
> > Well Kamesan indicated that this worked if a cpu became online.
> 
> I mean in the general case. There were tons of problems all over.
> 
Then, it's cpu hotplug matter, not memory hotplug.
cpu hotplug callback should prepaare 


	l3 = searchp->nodelists[node];
	BUG_ON(!l3);

before onlined. Rather than taking care of races.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
