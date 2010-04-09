Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 23AC2600375
	for <linux-mm@kvack.org>; Fri,  9 Apr 2010 04:46:16 -0400 (EDT)
Message-ID: <4BBEE920.9020502@redhat.com>
Date: Fri, 09 Apr 2010 11:45:20 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00 of 67] Transparent Hugepage Support #18
References: <patchbomb.1270691443@v2.random> <4BBDA43F.5030309@redhat.com> <4BBDC181.5040205@redhat.com>
In-Reply-To: <4BBDC181.5040205@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On 04/08/2010 02:44 PM, Avi Kivity wrote:
>
>> I'll try running this with a kernel build in parallel.
>
> Results here are less than stellar.  While khugepaged is pulling pages 
> together, something is breaking them apart.  Even after memory 
> pressure is removed, this behaviour continues.  Can it be that 
> compaction is tearing down huge pages?

ok, #19 is a different story.  A 1.2GB sort vs 'make -j12' and a cat of 
the source tree and some light swapping, all in 2GB RAM, didn't quite 
reach 1.2GB but came fairly close.  The sort was started while memory 
was quite low so it had to fight its way up, but even then khugepaged 
took less that 1.5 seconds total time after a _very_ long compile.

I observed huge pages being used for gcc as well, likely not bringing 
much performance since kernel compiles don't use a lot of memory per 
file.  I'll look at the link stage, that will probably use a lot of 
large pages.

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
