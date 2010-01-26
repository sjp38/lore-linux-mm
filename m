Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 72A806B0047
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 08:47:06 -0500 (EST)
Date: Tue, 26 Jan 2010 14:46:13 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 01 of 31] define MADV_HUGEPAGE
Message-ID: <20100126134613.GG30452@random.random>
References: <patchbomb.1264439931@v2.random>
 <edb236c55565378596ae.1264439932@v2.random>
 <20100126114101.GB16468@csn.ul.ie>
 <20100126123037.GE30452@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100126123037.GE30452@random.random>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, Christoph Hellwig <chellwig@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 26, 2010 at 01:30:37PM +0100, Andrea Arcangeli wrote:
> Very error prone that you can register in arch file, there are 4
> billions MADV_ available, the arch files shall be removed and it
> should all be defined in mman-common.h.

It seems 15 is free:

cd arch; grep -r MADV_ . |grep 15

so I will pick that one. Please nobody use number 15 or we
screwup...

I'll make a new #7 submit that also fixes one bug in
split_huge_page_mm/vma, find_vma should run on "address" not on
"address+HPAGE_PMD_SIZE-1" or it fails on the last hugepage on the vma
unless "address" is hugepage aligned (firefox flash tripped on this
last night, but thanks to the amount of BUG_ON that I added it was
immediate to fix). No more problems with java applets, flash etc...

 14:45:10 up 15:10,  5 users,  load average: 0.22, 0.17, 0.06

AnonPages:        612988 kB
AnonHugePages:     65536 kB

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
