Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id DCC686B01F9
	for <linux-mm@kvack.org>; Tue, 11 May 2010 13:21:50 -0400 (EDT)
Message-ID: <4BE9920C.3020901@redhat.com>
Date: Tue, 11 May 2010 13:21:16 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm,migration: Avoid race between shift_arg_pages() and
 rmap_walk() during migration by not migrating temporary stacks
References: <20100511085752.GM26611@csn.ul.ie> <alpine.LFD.2.00.1005111009500.3711@i5.linux-foundation.org>
In-Reply-To: <alpine.LFD.2.00.1005111009500.3711@i5.linux-foundation.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On 05/11/2010 01:11 PM, Linus Torvalds wrote:
> On Tue, 11 May 2010, Mel Gorman wrote:
>>
>> This patch closes the most important race in relation to exec and
>> migration. With it applied, the swapops bug is no longer triggering for
>> known problem workloads. If you pick it up, it should go with the other
>> mmmigration-* fixes in mm.
>
> Ack. _Much_ better and clearer.
>
> I'm not entirely sure we need that "maybe_stack" (if we need it, that
> would sound like a problem anyway), but I guess it can't hurt either.

Just a heads up - I am looking at creating a patch now that
allows us to _always_ lock the root anon_vma lock, when locking
the anon_vma.

That should take care of the other issue pretty cleanly, while
still allowing us to only walk the VMAs we have to walk in
places like rmap_walk.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
