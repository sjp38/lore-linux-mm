Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 4277F6B0031
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 14:37:36 -0400 (EDT)
Message-ID: <51FFF0DE.2000005@redhat.com>
Date: Mon, 05 Aug 2013 14:37:18 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 7/9] mm: zone_reclaim: compaction: export compact_zone_order()
References: <1375459596-30061-1-git-send-email-aarcange@redhat.com> <1375459596-30061-8-git-send-email-aarcange@redhat.com>
In-Reply-To: <1375459596-30061-8-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Johannes Weiner <jweiner@redhat.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rafael Aquini <aquini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Hush Bensen <hush.bensen@gmail.com>

On 08/02/2013 12:06 PM, Andrea Arcangeli wrote:
> Needed by zone_reclaim_mode compaction-awareness.
>
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
