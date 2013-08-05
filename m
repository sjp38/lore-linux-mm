Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id F08EC6B0034
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 14:38:14 -0400 (EDT)
Message-ID: <51FFF10B.6080308@redhat.com>
Date: Mon, 05 Aug 2013 14:38:03 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 8/9] mm: zone_reclaim: after a successful zone_reclaim
 check the min watermark
References: <1375459596-30061-1-git-send-email-aarcange@redhat.com> <1375459596-30061-9-git-send-email-aarcange@redhat.com>
In-Reply-To: <1375459596-30061-9-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Johannes Weiner <jweiner@redhat.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rafael Aquini <aquini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Hush Bensen <hush.bensen@gmail.com>

On 08/02/2013 12:06 PM, Andrea Arcangeli wrote:
> If we're in the fast path and we succeeded zone_reclaim(), it means we
> freed enough memory and we can use the min watermark to have some
> margin against concurrent allocations from other CPUs or interrupts.
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
