Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id A7C396B01EF
	for <linux-mm@kvack.org>; Sat, 17 Apr 2010 15:04:30 -0400 (EDT)
Date: Sat, 17 Apr 2010 12:05:31 -0700
From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: hugepages will matter more in the future
Message-ID: <20100417120531.0b86e959@infradead.org>
In-Reply-To: <4BC9FB64.5040009@redhat.com>
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
	<20100412042230.5d974e5d@infradead.org>
	<4BC30436.8070001@redhat.com>
	<20100417081218.4160f36b@infradead.org>
	<4BC9FB64.5040009@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Ingo Molnar <mingo@elte.hu>, Jason Garrett-Glaser <darkshikari@gmail.com>, Mike Galbraith <efault@gmx.de>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael
 S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Sat, 17 Apr 2010 21:18:12 +0300
> 
> Correct.  We're trying to reduce suckage from 2 cache misses per
> access (3 for virt), to 1 cache miss per access.  We're also freeing
> up space in the cache for data.
> 
> Saying the application already sucks isn't helping anything.

but the guy who's writing the application will already optimize for
this case...



-- 
Arjan van de Ven 	Intel Open Source Technology Centre
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
