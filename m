Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 91A4B6B0011
	for <linux-mm@kvack.org>; Fri, 27 May 2011 02:55:09 -0400 (EDT)
Date: Fri, 27 May 2011 08:55:01 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: mm: remove khugepaged double thp vmstat update with CONFIG_NUMA=n
Message-ID: <20110527065501.GB3143@redhat.com>
References: <20110526222218.GS19505@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110526222218.GS19505@random.random>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>

On Fri, May 27, 2011 at 12:22:18AM +0200, Andrea Arcangeli wrote:
> Subject: mm: remove khugepaged double thp vmstat update with CONFIG_NUMA=n
> 
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> Johannes noticed the vmstat update is already taken care of by
> khugepaged_alloc_hugepage() internally. The only places that are
> required to update the vmstat are the callers of alloc_hugepage
> (callers of khugepaged_alloc_hugepage aren't).
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> Reported-by: Johannes Weiner <jweiner@redhat.com>

Acked-by: Johannes Weiner <jweiner@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
