Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 22543900146
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 20:17:01 -0400 (EDT)
Message-ID: <4E431F62.5030704@redhat.com>
Date: Wed, 10 Aug 2011 20:16:34 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2 of 3] mremap: avoid sending one IPI per page
References: <patchbomb.1312649882@localhost> <cbe9e822c59a912e9f76.1312649884@localhost>
In-Reply-To: <cbe9e822c59a912e9f76.1312649884@localhost>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aarcange@redhat.com
Cc: linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <jweiner@redhat.com>, Hugh Dickins <hughd@google.com>

On 08/06/2011 12:58 PM, aarcange@redhat.com wrote:
> From: Andrea Arcangeli<aarcange@redhat.com>
>
> This replaces ptep_clear_flush() with ptep_get_and_clear() and a single
> flush_tlb_range() at the end of the loop, to avoid sending one IPI for each
> page.
>
> The mmu_notifier_invalidate_range_start/end section is enlarged accordingly but
> this is not going to fundamentally change things. It was more by accident that
> the region under mremap was for the most part still available for secondary
> MMUs: the primary MMU was never allowed to reliably access that region for the
> duration of the mremap (modulo trapping SIGSEGV on the old address range which
> sounds unpractical and flakey). If users wants secondary MMUs not to lose
> access to a large region under mremap

Userspace programs do not get reliable access to memory
that is currently being mremapped.  This patch does not
change that situation in the least.

> Signed-off-by: Andrea Arcangeli<aarcange@redhat.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
