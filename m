Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 77F3E6B0069
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 12:00:46 -0500 (EST)
Received: by vcbfk26 with SMTP id fk26so583675vcb.14
        for <linux-mm@kvack.org>; Tue, 22 Nov 2011 09:00:44 -0800 (PST)
Date: Wed, 23 Nov 2011 02:00:37 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 2/7] mm: compaction: Use synchronous compaction for
 /proc/sys/vm/compact_memory
Message-ID: <20111122170037.GB15253@barrios-laptop.redhat.com>
References: <1321900608-27687-1-git-send-email-mgorman@suse.de>
 <1321900608-27687-3-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1321900608-27687-3-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Nai Xia <nai.xia@gmail.com>, LKML <linux-kernel@vger.kernel.org>

On Mon, Nov 21, 2011 at 06:36:43PM +0000, Mel Gorman wrote:
> When asynchronous compaction was introduced, the
> /proc/sys/vm/compact_memory handler should have been updated to always
> use synchronous compaction. This did not happen so this patch addresses
> it. The assumption is if a user writes to /proc/sys/vm/compact_memory,
> they are willing for that process to stall.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>
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
