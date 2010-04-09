Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id E537160037E
	for <linux-mm@kvack.org>; Fri,  9 Apr 2010 13:45:41 -0400 (EDT)
Message-ID: <4BBF678B.1050803@redhat.com>
Date: Fri, 09 Apr 2010 20:44:43 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00 of 67] Transparent Hugepage Support #18
References: <patchbomb.1270691443@v2.random> <4BBDA43F.5030309@redhat.com> <4BBDC181.5040205@redhat.com> <4BBEE920.9020502@redhat.com> <20100409155040.GC5708@random.random>
In-Reply-To: <20100409155040.GC5708@random.random>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On 04/09/2010 06:50 PM, Andrea Arcangeli wrote:
>
>> ok, #19 is a different story.  A 1.2GB sort vs 'make -j12' and a cat of
>> the source tree and some light swapping, all in 2GB RAM, didn't quite
>> reach 1.2GB but came fairly close.  The sort was started while memory
>> was quite low so it had to fight its way up, but even then khugepaged
>> took less that 1.5 seconds total time after a _very_ long compile.
>>      
> Good. Also please check you're on
> 8707120d97e7052ffb45f9879efce8e7bd361711, with that one all bugs are
> ironed out, it's stable on all my systems under constant mixed heavy
> load (the same load would crash it in 1 hour with the memory
> compaction bug, or half a day with the anon-vma bugs and no memory
> compaction). 8707120d97e7052ffb45f9879efce8e7bd361711 is rock solid as
> far as I can tell.
>    

Yes, that's what I used.

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
