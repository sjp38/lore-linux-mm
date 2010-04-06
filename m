Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 17CF06B01EE
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 10:55:34 -0400 (EDT)
Date: Tue, 6 Apr 2010 15:55:13 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
Message-ID: <20100406145512.GE17882@csn.ul.ie>
References: <20100405193616.GA5125@elte.hu> <n2j84144f021004051326mab7cd8fbm949115748a3d78b6@mail.gmail.com> <alpine.LFD.2.00.1004051326380.21411@i5.linux-foundation.org> <t2q84144f021004051346o65f03e71r5b7bb19b433ce454@mail.gmail.com> <alpine.LFD.2.00.1004051347480.21411@i5.linux-foundation.org> <20100405232115.GM5825@random.random> <20100406093021.GC17882@csn.ul.ie> <BAA2AB49-DE66-4F22-B0E2-296522C2AF3E@mit.edu> <20100406111619.GD17882@csn.ul.ie> <13812DAC-4B53-4B6B-8725-EBC9E735AF96@mit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <13812DAC-4B53-4B6B-8725-EBC9E735AF96@mit.edu>
Sender: owner-linux-mm@kvack.org
To: Theodore Tso <tytso@MIT.EDU>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 06, 2010 at 09:13:20AM -0400, Theodore Tso wrote:
> 
> On Apr 6, 2010, at 7:16 AM, Mel Gorman wrote:
> 
> > 
> > Does this clarify why min_free_kbytes helps and why the "recommended"
> > value is what it is?
> 
> Thanks, this is really helpful. I wonder if it might be a good idea to
> have a boot command-line option which automatically sets vm.min_free_kbytes
> to the right value? 

I considered automatically adjusting it the first time huge pages are used,
as a command-line option or even a magic value writting to proc.  It's trivial
to implement each option, just haven't gotten around to doing it. There was
less pressure once the tool existed.

> Most administrators who are used to using hugepages,
> are most familiar with needing to set boot command-line options, and this way
> they won't need to try to find this new userspace utility. 

The utility covers a host of other use cases as well e.g. creates mount
points, sets quota, sizes pools (both static and dynamic), reports on the
current state of the system, can auto tune shmem settings etc.

> I was looking
> for hugeadm on Ubuntu, for example, and I couldn't find it.

It's relatively recent and there isn't debian packaging for it (although an
old one was sent to debian mentors once upon a time but never finished). It's
on the TODO list of infinite woe to finish that packaging and go through
Debian so it ends up in Ubuntu eventually.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
