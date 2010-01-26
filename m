Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 1DF4D6B0089
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 08:59:18 -0500 (EST)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 00 of 31] Transparent Hugepage support #7
Message-Id: <patchbomb.1264513915@v2.random>
Date: Tue, 26 Jan 2010 14:51:55 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, Christoph Hellwig <chellwig@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Hello,

this is an update that notably fixes one bug in split_huge_page_mm/vma that
was calling find_vma on "address+HPAGE_PMD_SIZE-1" even if address wasn't
always hpage aligned, so it was failing on the last hugepage of the vma unless
"address" was hugepage aligned (firefox flash tripped on this last night, but
thanks to the amount of BUG_ON that I added it was immediate to fix). No more
problems with java applets, flash etc...

This also moves the MADV_HUGEPAGE to 15 to avoid tripping on parisc (this is
just in case, no idea if parisc is planning to support transparent hugepage or
not). Not sure why there's not just one file for all MADV_ defines, there are
4 billions of madv possible with this api so it looks unnecessary to have
per-arch defines.

So this is running fine, no more bugchecks tripping on mprotect and laptop was
rock solid so far.

 14:45:10 up 15:10,  5 users,  load average: 0.22, 0.17, 0.06

 AnonPages:        612988 kB
 AnonHugePages:     65536 kB

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
