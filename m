Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 4DC586B0055
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 17:35:56 -0400 (EDT)
Message-ID: <4A414ADC.5080402@redhat.com>
Date: Tue, 23 Jun 2009 17:36:28 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] hugetlb: fault flags instead of write_access
References: <alpine.LFD.2.01.0906211331480.3240@localhost.localdomain> <Pine.LNX.4.64.0906231345001.19552@sister.anvils>
In-Reply-To: <Pine.LNX.4.64.0906231345001.19552@sister.anvils>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> handle_mm_fault() is now passing fault flags rather than write_access
> down to hugetlb_fault(), so better recognize that in hugetlb_fault(),
> and in hugetlb_no_page().
> 
> Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
