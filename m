Message-ID: <45DB5365.2090207@redhat.com>
Date: Tue, 20 Feb 2007 15:00:37 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] mm: balance_dirty_pages() vs throttle_vm_writeout()
 deadlock
References: <1171986565.23046.5.camel@twins>
In-Reply-To: <1171986565.23046.5.camel@twins>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, Trond Myklebust <Trond.Myklebust@netapp.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Peter Zijlstra wrote:

> However unstable pages don't go away automagickally, they need a push. While
> balance_dirty_pages() does this push, throttle_vm_writeout() doesn't. So we can
> sit here ad infintum.

That would certainly explain the bad interactive behaviour when
doing heavy NFS writeouts!

> Hence I propose to remove the NR_UNSTABLE_NFS count from throttle_vm_writeout().

As long as something else ensures that the unstable pages still
get taken care of like they should, I guess...

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
