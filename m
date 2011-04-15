Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 318A3900086
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 09:23:24 -0400 (EDT)
Message-ID: <4DA846BF.7020504@redhat.com>
Date: Fri, 15 Apr 2011 09:23:11 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: Check if PTE is already allocated during page fault
References: <20110415101248.GB22688@suse.de>
In-Reply-To: <20110415101248.GB22688@suse.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: akpm@linux-foundation.org, Andrea Arcangeli <aarcange@redhat.com>, raz ben yehuda <raziebe@gmail.com>, kosaki.motohiro@jp.fujitsu.com, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, stable@kernel.org

On 04/15/2011 06:12 AM, Mel Gorman wrote:

> This patch simply re-adds the check normally done by pte_alloc_map to
> check if the PTE needs to be allocated before taking the page table
> lock. The effect is noticable in page_test from aim9.

> Reported-by: Raz Ben Yehuda<raziebe@gmail.com>
> Signed-off-by: Mel Gorman<mgorman@suse.de>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
