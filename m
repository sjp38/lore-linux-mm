Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 8B7756B004A
	for <linux-mm@kvack.org>; Wed, 11 Apr 2012 14:14:52 -0400 (EDT)
Message-ID: <4F85BEB5.6080702@redhat.com>
Date: Wed, 11 Apr 2012 13:26:13 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] mm: vmscan: Do not stall on writeback during memory
 compaction
References: <1334162298-18942-1-git-send-email-mgorman@suse.de> <1334162298-18942-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1334162298-18942-3-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 04/11/2012 12:38 PM, Mel Gorman wrote:
> This patch stops reclaim/compaction entering sync reclaim as this was only
> intended for lumpy reclaim and an oversight. Page migration has its own
> logic for stalling on writeback pages if necessary and memory compaction
> is already using it.
>
> Waiting on page writeback is bad for a number of reasons but the primary
> one is that waiting on writeback to a slow device like USB can take a
> considerable length of time. Page reclaim instead uses wait_iff_congested()
> to throttle if too many dirty pages are being scanned.
>
> Signed-off-by: Mel Gorman<mgorman@suse.de>

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
