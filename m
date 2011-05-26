Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 3DDB76B0011
	for <linux-mm@kvack.org>; Thu, 26 May 2011 19:30:52 -0400 (EDT)
Message-ID: <4DDEE2A5.1050508@redhat.com>
Date: Thu, 26 May 2011 19:30:45 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: mm: remove khugepaged double thp vmstat update with CONFIG_NUMA=n
References: <20110526222218.GS19505@random.random>
In-Reply-To: <20110526222218.GS19505@random.random>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Johannes Weiner <jweiner@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>

On 05/26/2011 06:22 PM, Andrea Arcangeli wrote:
> Subject: mm: remove khugepaged double thp vmstat update with CONFIG_NUMA=n
>
> From: Andrea Arcangeli<aarcange@redhat.com>
>
> Johannes noticed the vmstat update is already taken care of by
> khugepaged_alloc_hugepage() internally. The only places that are
> required to update the vmstat are the callers of alloc_hugepage
> (callers of khugepaged_alloc_hugepage aren't).
>
> Signed-off-by: Andrea Arcangeli<aarcange@redhat.com>
> Reported-by: Johannes Weiner<jweiner@redhat.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
