Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 5DF196B01B1
	for <linux-mm@kvack.org>; Thu, 20 May 2010 19:08:10 -0400 (EDT)
Message-ID: <4BF5C0B9.9080908@redhat.com>
Date: Thu, 20 May 2010 19:07:37 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 6/5] adjust mm_take_all_locks to anon-vma-root locking
References: <20100512133815.0d048a86@annuminas.surriel.com> <20100520224258.GA12100@random.random>
In-Reply-To: <20100520224258.GA12100@random.random>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, Linux-MM <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On 05/20/2010 06:42 PM, Andrea Arcangeli wrote:
> This is needed as 6/5 to avoid lockups in mm_take_all_locks.
>
> ======
> Subject: adjust mm_take_all_locks to the root_anon_vma locking
>
> From: Andrea Arcangeli<aarcange@redhat.com>
>
> Track the anon_vma->root->lock.
>
> Signed-off-by: Andrea Arcangeli<aarcange@redhat.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
