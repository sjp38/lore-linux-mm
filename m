Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 81ABE6B002D
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 16:46:40 -0500 (EST)
Message-ID: <4ECAC6C0.3090202@redhat.com>
Date: Mon, 21 Nov 2011 16:46:40 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/5] mm: compaction: Use synchronous compaction for /proc/sys/vm/compact_memory
References: <1321635524-8586-1-git-send-email-mgorman@suse.de> <1321635524-8586-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1321635524-8586-3-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On 11/18/2011 11:58 AM, Mel Gorman wrote:
> When asynchronous compaction was introduced, the
> /proc/sys/vm/compact_memory handler should have been updated to always
> use synchronous compaction. This did not happen so this patch addresses
> it. The assumption is if a user writes to /proc/sys/vm/compact_memory,
> they are willing for that process to stall.
>
> Signed-off-by: Mel Gorman<mgorman@suse.de>

Reviewed-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
