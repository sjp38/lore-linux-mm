Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 72D796B0047
	for <linux-mm@kvack.org>; Thu, 18 Feb 2010 19:07:49 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1J07cZX026358
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 19 Feb 2010 09:07:38 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 165A645DE4E
	for <linux-mm@kvack.org>; Fri, 19 Feb 2010 09:07:38 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id D80DA45DE4C
	for <linux-mm@kvack.org>; Fri, 19 Feb 2010 09:07:37 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 9D03BE08001
	for <linux-mm@kvack.org>; Fri, 19 Feb 2010 09:07:37 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 53424E78004
	for <linux-mm@kvack.org>; Fri, 19 Feb 2010 09:07:37 +0900 (JST)
Date: Fri, 19 Feb 2010 09:04:06 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 05/12] Memory compaction core
Message-Id: <20100219090406.d3903e05.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1002181335270.7351@router.home>
References: <1265976059-7459-1-git-send-email-mel@csn.ul.ie>
	<1265976059-7459-6-git-send-email-mel@csn.ul.ie>
	<20100216170014.7309.A69D9226@jp.fujitsu.com>
	<20100216084800.GC26086@csn.ul.ie>
	<alpine.DEB.2.00.1002160849460.18275@router.home>
	<20100216145943.GA997@csn.ul.ie>
	<alpine.DEB.2.00.1002181335270.7351@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 18 Feb 2010 13:37:35 -0600 (CST)
Christoph Lameter <cl@linux-foundation.org> wrote:

> On Tue, 16 Feb 2010, Mel Gorman wrote:
> 
> > > Oh there are numerous ZONE_DMA pressure issues if you have ancient /
> > > screwed up hardware that can only operate on DMA or DMA32 memory.
> > >
> >
> > I've never ran into the issue. I was under the impression that the only
> > device that might care these days are floopy disks.
> 
> Kame-san had an issue a year or so ago.
> 
Yes. But my customer doesn't use the newest things...
In server area, recent hardware(64bit) and drivers tend not to cause the issue.
I'm not sure there are some driver which still set their DMA mask wrong and
require bounce buffer. But I guess that I'll have to see DMA-zone issue in
customer support still in (early) RHEL6.

Considering other area, I hear OOM-issue from notebook/desktop users, they don't
equip swap. I think some of devices are still 32bit if 64bit isn't required for them.
I wonder problems on lower-zone still exists for 32bit devices users.
In the view point as kernels for x86-32 still support ZONE_DMA
for ISA bus...we shouldn't assume there are no legacy. 

But yes, it may not be very important to implement inter-zone moving. It's not
for compaction, but just for memory-reclaim. And it has some complication.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
