Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 92F2E6B0069
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 08:09:23 -0500 (EST)
Date: Mon, 21 Nov 2011 13:09:15 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 7/8] Revert "vmscan: abort reclaim/compaction if
 compaction can proceed"
Message-ID: <20111121130915.GF19415@suse.de>
References: <1321635524-8586-1-git-send-email-mgorman@suse.de>
 <1321732460-14155-8-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1321732460-14155-8-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Minchan Kim <minchan.kim@gmail.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <jweiner@redhat.com>, linux-kernel@vger.kernel.org

On Sat, Nov 19, 2011 at 08:54:19PM +0100, Andrea Arcangeli wrote:
> This reverts commit e0c23279c9f800c403f37511484d9014ac83adec.
> 
> If reclaim runs with an high order allocation, it means compaction
> failed. That means something went wrong with compaction so we can't
> stop reclaim too. We can't assume it failed and was deferred because
> of the too low watermarks in compaction_suitable only, it may have
> failed for other reasons.
> 

When Rik was testing with THP enabled, he found that there was way
too much memory free on his machine. The problem was that THP caused
reclaim to be too aggressive and that's what led to that pair of
patches. While I do not think it was confirmed, the expectation was
that the performance of workloads whose working set size was close
to total physical RAM and mostly filesystem-backed files would suffer
if THP was enabled.

In other words, reverting these patches needs to be a last resort.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
