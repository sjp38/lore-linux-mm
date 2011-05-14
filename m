Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 162FC6B0023
	for <linux-mm@kvack.org>; Sat, 14 May 2011 12:31:01 -0400 (EDT)
Received: by qyk2 with SMTP id 2so981033qyk.14
        for <linux-mm@kvack.org>; Sat, 14 May 2011 09:30:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1305295404-12129-2-git-send-email-mgorman@suse.de>
References: <1305295404-12129-1-git-send-email-mgorman@suse.de>
	<1305295404-12129-2-git-send-email-mgorman@suse.de>
Date: Sun, 15 May 2011 01:30:57 +0900
Message-ID: <BANLkTik7+9TcA0HMgKeMZy-L0R+1RN2_rQ@mail.gmail.com>
Subject: Re: [PATCH 1/4] mm: vmscan: Correct use of pgdat_balanced in sleeping_prematurely
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, James Bottomley <James.Bottomley@hansenpartnership.com>, Colin King <colin.king@canonical.com>, Raghavendra D Prabhu <raghu.prabhu13@gmail.com>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>

On Fri, May 13, 2011 at 11:03 PM, Mel Gorman <mgorman@suse.de> wrote:
> Johannes Weiner poined out that the logic in commit [1741c877: mm:
> kswapd: keep kswapd awake for high-order allocations until a percentage
> of the node is balanced] is backwards. Instead of allowing kswapd to go
> to sleep when balancing for high order allocations, it keeps it kswapd
> running uselessly.
>
> From-but-was-not-signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Will-sign-off-after-Johannes: Mel Gorman <mgorman@suse.de>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

Nice catch! Hannes.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
