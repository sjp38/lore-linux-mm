Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id F2A498D0004
	for <linux-mm@kvack.org>; Thu,  1 Nov 2012 17:49:19 -0400 (EDT)
Message-ID: <5092EE57.1030605@redhat.com>
Date: Thu, 01 Nov 2012 17:49:11 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 2/6] mm: check rb_subtree_gap correctness
References: <1351679605-4816-1-git-send-email-walken@google.com> <1351679605-4816-3-git-send-email-walken@google.com>
In-Reply-To: <1351679605-4816-3-git-send-email-walken@google.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org

On 10/31/2012 06:33 AM, Michel Lespinasse wrote:
> When CONFIG_DEBUG_VM_RB is enabled, check that rb_subtree_gap is
> correctly set for every vma and that mm->highest_vm_end is also correct.
>
> Also add an explicit 'bug' variable to track if browse_rb() detected any
> invalid condition.

Looks somewhat familiar :)

> Signed-off-by: Michel Lespinasse <walken@google.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
