Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 5B7266B01EE
	for <linux-mm@kvack.org>; Mon, 12 Apr 2010 07:21:39 -0400 (EDT)
Date: Mon, 12 Apr 2010 04:22:30 -0700
From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: hugepages will matter more in the future
Message-ID: <20100412042230.5d974e5d@infradead.org>
In-Reply-To: <20100411115229.GB10952@elte.hu>
References: <20100410194751.GA23751@elte.hu>
	<4BC0DE84.3090305@redhat.com>
	<4BC0E2C4.8090101@redhat.com>
	<q2s28f2fcbc1004101349ye3e44c9cl4f0c3605c8b3ffd3@mail.gmail.com>
	<4BC0E556.30304@redhat.com>
	<4BC19663.8080001@redhat.com>
	<v2q28f2fcbc1004110237w875d3ec5z8f545c40bcbdf92a@mail.gmail.com>
	<4BC19916.20100@redhat.com>
	<20100411110015.GA10149@elte.hu>
	<4BC1B034.4050302@redhat.com>
	<20100411115229.GB10952@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Avi Kivity <avi@redhat.com>, Jason Garrett-Glaser <darkshikari@gmail.com>, Mike Galbraith <efault@gmx.de>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael
 S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Sun, 11 Apr 2010 13:52:29 +0200
Ingo Molnar <mingo@elte.hu> wrote:

> 
> Also, the proportion of 4K:2MB is a fixed constant, and CPUs dont
> grow their TLB caches as much as typical RAM size grows: they'll grow
> it according to the _mean_ working set size - while the 'max' working
> set gets larger and larger due to the increasing [proportional] gap
> to RAM size.

> This is why i think we should think about hugetlb support today and
> this is why i think we should consider elevating hugetlbs to the next
> level of built-in Linux VM support.


I respectfully disagree with your analysis.
While it is true that the number of "level 1" tlb entries has not kept
up with ram or application size, the CPU designers have made it so that
there effectively is a "level 2" (or technically, level 3) in the cache.

A tlb miss from cache is so cheap that in almost all cases (you can
cheat it by using only 1 byte per page, walking randomly through memory
and having a strict ordering between those 1 byte accesses) it is
hidden in the out of order engine.

So in practice, for many apps, as long as the CPU cache scales with
application size the TLB more or less scales too.

Now hugepages have some interesting other advantages, namely they save
pagetable memory..which for something like TPC-C on a fork based
database can be a measureable win.


-- 
Arjan van de Ven 	Intel Open Source Technology Centre
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
