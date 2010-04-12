Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 2A9476B01E3
	for <linux-mm@kvack.org>; Mon, 12 Apr 2010 09:34:55 -0400 (EDT)
Message-ID: <4BC3213E.40409@redhat.com>
Date: Mon, 12 Apr 2010 16:33:50 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: hugepages will matter more in the future
References: <4BC0E2C4.8090101@redhat.com> <q2s28f2fcbc1004101349ye3e44c9cl4f0c3605c8b3ffd3@mail.gmail.com> <4BC0E556.30304@redhat.com> <4BC19663.8080001@redhat.com> <v2q28f2fcbc1004110237w875d3ec5z8f545c40bcbdf92a@mail.gmail.com> <4BC19916.20100@redhat.com> <20100411110015.GA10149@elte.hu> <4BC1B034.4050302@redhat.com> <20100411115229.GB10952@elte.hu> <20100412042230.5d974e5d@infradead.org> <20100412133019.GZ5656@random.random>
In-Reply-To: <20100412133019.GZ5656@random.random>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Arjan van de Ven <arjan@infradead.org>, Ingo Molnar <mingo@elte.hu>, Jason Garrett-Glaser <darkshikari@gmail.com>, Mike Galbraith <efault@gmx.de>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On 04/12/2010 04:30 PM, Andrea Arcangeli wrote:
> On Mon, Apr 12, 2010 at 04:22:30AM -0700, Arjan van de Ven wrote:
>    
>> Now hugepages have some interesting other advantages, namely they save
>> pagetable memory..which for something like TPC-C on a fork based
>> database can be a measureable win.
>>      
> It doesn't save pagetable memory (as in `grep MemFree
> /proc/meminfo`).

So where does the pagetable go?

> To achive that we'd need to return -ENOMEM from
> split_huge_page_pmd and split_huge_page, which would complicate things
> significantly. I'd prefer if we could get rid gradually of
> split_huge_page_pmd calls instead of having to handle a retval in
> several inner nested functions that don't contemplate returning error
> like all their callers.
>
> I think the saving in pagetables isn't really interesting... it's a
> couple of gigabytes but it doesn't move the needle as much as being
> able to boost CPU performance.
>    

Fork-based (or process+shm based, like Oracle) replicate the page tables 
per process, so it's N * 0.2%, which would be quite large.  We could 
share pmds for large shared memory areas, but it wouldn't be easy.


-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
