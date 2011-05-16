Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id B190A6B0023
	for <linux-mm@kvack.org>; Mon, 16 May 2011 10:30:51 -0400 (EDT)
Message-ID: <4DD134FC.3000608@redhat.com>
Date: Mon, 16 May 2011 10:30:20 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/4] mm: vmscan: Correct use of pgdat_balanced in sleeping_prematurely
References: <1305295404-12129-1-git-send-email-mgorman@suse.de> <1305295404-12129-2-git-send-email-mgorman@suse.de>
In-Reply-To: <1305295404-12129-2-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, James Bottomley <James.Bottomley@HansenPartnership.com>, Colin King <colin.king@canonical.com>, Raghavendra D Prabhu <raghu.prabhu13@gmail.com>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>

On 05/13/2011 10:03 AM, Mel Gorman wrote:
> Johannes Weiner poined out that the logic in commit [1741c877: mm:
> kswapd: keep kswapd awake for high-order allocations until a percentage
> of the node is balanced] is backwards. Instead of allowing kswapd to go
> to sleep when balancing for high order allocations, it keeps it kswapd
> running uselessly.
>
> From-but-was-not-signed-off-by: Johannes Weiner<hannes@cmpxchg.org>
> Will-sign-off-after-Johannes: Mel Gorman<mgorman@suse.de>

Reviewed-by: Rik van Riel<riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
