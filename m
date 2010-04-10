Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id B73296B01F5
	for <linux-mm@kvack.org>; Sat, 10 Apr 2010 15:03:34 -0400 (EDT)
Date: Sat, 10 Apr 2010 21:02:33 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
Message-ID: <20100410190233.GA30882@elte.hu>
References: <alpine.LFD.2.00.1004051326380.21411@i5.linux-foundation.org>
 <t2q84144f021004051346o65f03e71r5b7bb19b433ce454@mail.gmail.com>
 <alpine.LFD.2.00.1004051347480.21411@i5.linux-foundation.org>
 <20100405232115.GM5825@random.random>
 <alpine.LFD.2.00.1004051636060.21411@i5.linux-foundation.org>
 <20100406011345.GT5825@random.random>
 <alpine.LFD.2.00.1004051836000.5870@i5.linux-foundation.org>
 <alpine.LFD.2.00.1004051917310.3487@i5.linux-foundation.org>
 <20100406090813.GA14098@elte.hu>
 <20100410184750.GJ5708@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100410184750.GJ5708@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>


* Andrea Arcangeli <aarcange@redhat.com> wrote:

> [...]
> 
> This is already fully usable and works great, and as Avi showed it boosts 
> even a sort on host by 6%, think about HPC applications, and soon I hope to 
> boost gcc on host by 6% (and of >15% in guest with NPT/EPT) by extending 
> vm_end in 2M chunks in glibc, at least for those huge gcc builds taking 
> >200M like translate.o of qemu-kvm... (so I hope soon gcc running on KVM 
> guest, thanks to EPT/NPT, will run faster than on mainline kernel without 
> transparent hugepages on bare metal).

I think what would be needed is some non-virtualization speedup example of a 
'non-special' workload, running on the native/host kernel. 'sort' is an 
interesting usecase - could it be patched to use hugepages if it has to sort 
through lots of data?

Is it practical to run something like a plain make -jN kernel compile all in 
hugepages, and see a small but measurable speedup?

Although it's not an ideal workload for computational speedups at all because 
a lot of the time we spend in a kernel build is really buildup/teardown of 
process state/context and similar 'administrative' overhead, while the true 
'compilation work' is just a burst of a few dozen milliseconds and then we 
tear down all the state again. (It's very inefficient really.)

Something like GIMP calculations would be a lot more representative of the 
speedup potential. Is it possible to run the GIMP with transparent hugepages 
enabled for it?

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
