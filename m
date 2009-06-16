Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 1167E6B0082
	for <linux-mm@kvack.org>; Tue, 16 Jun 2009 17:54:44 -0400 (EDT)
Message-ID: <4A381506.20102@redhat.com>
Date: Tue, 16 Jun 2009 17:56:22 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 2/2] mm: remove task assumptions from swap token
References: <Pine.LNX.4.64.0906162152250.12770@sister.anvils> <1245189037-22961-2-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1245189037-22961-2-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <ieidus@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Johannes Weiner wrote:
> From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> 
> grab_swap_token() should not make any assumptions about the running
> process as the swap token is an attribute of the address space and the
> faulting mm is not necessarily current->mm.
> 
> This fixes get_user_pages() from kernel threads which would blow up
> when encountering a swapped out page and grab_swap_token()
> dereferencing the unset for kernel threads current->mm.
> 
> Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
