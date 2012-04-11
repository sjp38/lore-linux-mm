Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 124FE6B0083
	for <linux-mm@kvack.org>; Wed, 11 Apr 2012 14:56:24 -0400 (EDT)
Message-ID: <4F85BEE1.1050607@redhat.com>
Date: Wed, 11 Apr 2012 13:26:57 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] mm: vmscan: Remove reclaim_mode_t
References: <1334162298-18942-1-git-send-email-mgorman@suse.de> <1334162298-18942-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1334162298-18942-4-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 04/11/2012 12:38 PM, Mel Gorman wrote:
> There is little motiviation for reclaim_mode_t once RECLAIM_MODE_[A]SYNC
> and lumpy reclaim have been removed. This patch gets rid of reclaim_mode_t
> as well and improves the documentation about what reclaim/compaction is
> and when it is triggered.
>
> Signed-off-by: Mel Gorman<mgorman@suse.de>

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
