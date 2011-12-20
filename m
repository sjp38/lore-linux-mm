Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 6EE256B005C
	for <linux-mm@kvack.org>; Tue, 20 Dec 2011 11:04:22 -0500 (EST)
Message-ID: <4EF0B1FA.20209@redhat.com>
Date: Tue, 20 Dec 2011 11:04:10 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] consider swap space when we decide compaction goes or
 not
References: <1324363653-18220-1-git-send-email-minchan@kernel.org>
In-Reply-To: <1324363653-18220-1-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>

On 12/20/2011 01:47 AM, Minchan Kim wrote:
> It's pointless to go reclaiming when we have no swap space
> and lots of anon pages in inactive list.
>
> Cc: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>
> Cc: Mel Gorman<mgorman@suse.de>
> Cc: Rik van Riel<riel@redhat.com>
> Cc: Johannes Weiner<jweiner@redhat.com>
> Cc: Andrea Arcangeli<aarcange@redhat.com>
> Signed-off-by: Minchan Kim<minchan@kernel.org>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
