Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 728836B01E3
	for <linux-mm@kvack.org>; Sun, 11 Apr 2010 08:02:59 -0400 (EDT)
Message-ID: <4BC1BA0D.1050904@redhat.com>
Date: Sun, 11 Apr 2010 15:01:17 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: hugepages will matter more in the future
References: <20100410194751.GA23751@elte.hu> <4BC0DE84.3090305@redhat.com> <4BC0E2C4.8090101@redhat.com> <q2s28f2fcbc1004101349ye3e44c9cl4f0c3605c8b3ffd3@mail.gmail.com> <4BC0E556.30304@redhat.com> <4BC19663.8080001@redhat.com> <v2q28f2fcbc1004110237w875d3ec5z8f545c40bcbdf92a@mail.gmail.com> <4BC19916.20100@redhat.com> <20100411110015.GA10149@elte.hu> <4BC1B034.4050302@redhat.com> <20100411115229.GB10952@elte.hu>
In-Reply-To: <20100411115229.GB10952@elte.hu>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Jason Garrett-Glaser <darkshikari@gmail.com>, Mike Galbraith <efault@gmx.de>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Arjan van de Ven <arjan@infradead.org>
List-ID: <linux-mm.kvack.org>

On 04/11/2010 02:52 PM, Ingo Molnar wrote:
>
> Put in a different way: this slow, gradual phsyical process causes data-cache
> misses to become 'colder and colder': in essence a portion of the worst-case
> TLB miss cost gets added to the average data-cache miss cost on more and more
> workloads. (Even without any nested-pagetables or other virtualization
> considerations.) The CPU can do nothing about this - even if it stays in a
> golden balance with typical workloads.
>    

This is the essence and which is why we really need transparent 
hugetlb.  Both the tlb and the caches are way to small to handle the 
millions of pages that are common now.

> This is why i think we should think about hugetlb support today and this is
> why i think we should consider elevating hugetlbs to the next level of
> built-in Linux VM support.
>    

Agreed, with s/today/yesterday/.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
