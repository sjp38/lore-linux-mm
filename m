Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 5766D6B00FA
	for <linux-mm@kvack.org>; Wed, 25 Feb 2009 16:31:42 -0500 (EST)
Message-ID: <49A5B8AE.3060701@redhat.com>
Date: Wed, 25 Feb 2009 16:31:26 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch] mm: don't free swap slots on page deactivation
References: <20090225023830.GA1611@cmpxchg.org> <20090225192550.GA5645@cmpxchg.org>
In-Reply-To: <20090225192550.GA5645@cmpxchg.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Johannes Weiner wrote:
> The pagevec_swap_free() at the end of shrink_active_list() was
> introduced in 68a22394 "vmscan: free swap space on swap-in/activation"
> when shrink_active_list() was still rotating referenced active pages.
> 
> In 7e9cd48 "vmscan: fix pagecache reclaim referenced bit check" this
> was changed, the rotating removed but the pagevec_swap_free() after
> the rotation loop was forgotten, applying now to the pagevec of the
> deactivation loop instead.
> 
> Now swap space is freed for deactivated pages.  And only for those
> that happen to be on the pagevec after the deactivation loop.
> 
> Complete 7e9cd48 and remove the rest of the swap freeing.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Rik van Riel <riel@redhat.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
