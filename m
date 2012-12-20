Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id A27986B005A
	for <linux-mm@kvack.org>; Thu, 20 Dec 2012 17:43:43 -0500 (EST)
Message-ID: <50D3947F.2060503@oracle.com>
Date: Thu, 20 Dec 2012 17:43:11 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH] ksm: make rmap walks more scalable
References: <alpine.LNX.2.00.1212191735530.25409@eggly.anvils> <alpine.LNX.2.00.1212191742440.25409@eggly.anvils> <50D387FD.4020008@oracle.com> <alpine.LNX.2.00.1212201409170.977@eggly.anvils>
In-Reply-To: <alpine.LNX.2.00.1212201409170.977@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Mel Gorman <mgorman@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Petr Holasek <pholasek@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 12/20/2012 05:37 PM, Hugh Dickins wrote:
> On Thu, 20 Dec 2012, Sasha Levin wrote:
>> On 12/19/2012 08:44 PM, Hugh Dickins wrote:
>>> The rmap walks in ksm.c are like those in rmap.c:
>>> they can safely be done with anon_vma_lock_read().
>>>
>>> Signed-off-by: Hugh Dickins <hughd@google.com>
>>> ---
>>
>> Hi Hugh,
>>
>> This patch didn't fix the ksm oopses I'm seeing.
> 
> I wouldn't expect it to (and should certainly have mentioned oopses
> in the commit message if I'd intended): this patch was merely an
> optimization/clarification of a commit gone in for 3.8-rc1.
> 
> Understandable misunderstanding: you took my Cc too seriously,
> I just thought I'd better keep Petr in the loop on current changes
> to ksm.c, and foolishly kept you in too ;)
> 
> Your oopses are on linux-next, which as of 20121220 still had Petr's
> nice but buggy NUMA KSM patch in: it should go away when Stephen gets
> a fresh mm update from Andrew, then reappear once his v6 goes into mm.
> 
> To stop these oopses in get_mergeable_page (inlined in
> unstable_tree_search_insert) you need the patch I showed on
> Tuesday, which I hope he'll merge in for his v6.  That doesn't fix
> all of the problems, but hopefully all that you'll encounter before
> I've devised a fix for the separate stale stable_nodes issue.

My bad! I thought that this is the finalized version of the patch from
Tuesday and was surprised when the oops was still there :)

fwiw I'll use this to report that I'm not seeing any unexpected behaviour
with this patch applied.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
