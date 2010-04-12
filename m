Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 741DC6B01E3
	for <linux-mm@kvack.org>; Mon, 12 Apr 2010 09:32:43 -0400 (EDT)
Date: Mon, 12 Apr 2010 15:30:19 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: hugepages will matter more in the future
Message-ID: <20100412133019.GZ5656@random.random>
References: <4BC0E2C4.8090101@redhat.com>
 <q2s28f2fcbc1004101349ye3e44c9cl4f0c3605c8b3ffd3@mail.gmail.com>
 <4BC0E556.30304@redhat.com>
 <4BC19663.8080001@redhat.com>
 <v2q28f2fcbc1004110237w875d3ec5z8f545c40bcbdf92a@mail.gmail.com>
 <4BC19916.20100@redhat.com>
 <20100411110015.GA10149@elte.hu>
 <4BC1B034.4050302@redhat.com>
 <20100411115229.GB10952@elte.hu>
 <20100412042230.5d974e5d@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100412042230.5d974e5d@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Arjan van de Ven <arjan@infradead.org>
Cc: Ingo Molnar <mingo@elte.hu>, Avi Kivity <avi@redhat.com>, Jason Garrett-Glaser <darkshikari@gmail.com>, Mike Galbraith <efault@gmx.de>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Mon, Apr 12, 2010 at 04:22:30AM -0700, Arjan van de Ven wrote:
> Now hugepages have some interesting other advantages, namely they save
> pagetable memory..which for something like TPC-C on a fork based
> database can be a measureable win.

It doesn't save pagetable memory (as in `grep MemFree
/proc/meminfo`). To achive that we'd need to return -ENOMEM from
split_huge_page_pmd and split_huge_page, which would complicate things
significantly. I'd prefer if we could get rid gradually of
split_huge_page_pmd calls instead of having to handle a retval in
several inner nested functions that don't contemplate returning error
like all their callers.

I think the saving in pagetables isn't really interesting... it's a
couple of gigabytes but it doesn't move the needle as much as being
able to boost CPU performance.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
