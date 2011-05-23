Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id B97266B0012
	for <linux-mm@kvack.org>; Mon, 23 May 2011 11:46:46 -0400 (EDT)
Received: by qyk30 with SMTP id 30so4176122qyk.14
        for <linux-mm@kvack.org>; Mon, 23 May 2011 08:46:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1306144435-2516-2-git-send-email-mgorman@suse.de>
References: <1306144435-2516-1-git-send-email-mgorman@suse.de>
	<1306144435-2516-2-git-send-email-mgorman@suse.de>
Date: Tue, 24 May 2011 00:46:44 +0900
Message-ID: <BANLkTi=T6R58_Z3UQTB6nUtRb9240dm0Sw@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm: vmscan: Correct use of pgdat_balanced in sleeping_prematurely
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, James Bottomley <James.Bottomley@hansenpartnership.com>, Colin King <colin.king@canonical.com>, Raghavendra D Prabhu <raghu.prabhu13@gmail.com>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>, stable <stable@kernel.org>

On Mon, May 23, 2011 at 6:53 PM, Mel Gorman <mgorman@suse.de> wrote:
> From: Johannes Weiner <hannes@cmpxchg.org>
>
> Johannes Weiner poined out that the logic in commit [1741c877: mm:
> kswapd: keep kswapd awake for high-order allocations until a percentage
> of the node is balanced] is backwards. Instead of allowing kswapd to go
> to sleep when balancing for high order allocations, it keeps it kswapd
> running uselessly.
>
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> Reviewed-by: Rik van Riel <riel@redhat.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
