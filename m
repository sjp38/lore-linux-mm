Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id CFE506B0078
	for <linux-mm@kvack.org>; Tue,  9 Mar 2010 14:44:11 -0500 (EST)
Message-Id: <20100309193901.207868642@redhat.com>
Date: Tue, 09 Mar 2010 20:39:01 +0100
From: aarcange@redhat.com
Subject: [patch 00/35] Transparent Hugepage support #13
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

Hello,

This is against 2.6.34-rc1, no other change compared to #12 other than
disabling defrag for anything but khugepaged because current direct reclaim is
too slow to run it for hugepages allocations during page faults. We'll enable
it again for MADV_HUGEPAGE page faults later with memory compaction when there
will be better chance that it's useful CPU work.

I assume if this will be merged the "memory compaction core" from Mel will plug
nicely on top of this by altering alloc_hugepage() accordingly.

Hopefully this is polished enough, the main gripe is left is the #ifdef in the
futex code pointed out by Peter, but without knowing the details of gup_fast of
whatever new architecture that will be able to mix regular pages and hugepages
in the same vma, it's hard to tell what is the cleanest way to abstract that
code. Feel free to give a direction on how to change it, if that patch isn't
polished enough.

	http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.34-rc1/transparent-hugepage-13/

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
