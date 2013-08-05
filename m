Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id A39F56B0033
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 14:36:47 -0400 (EDT)
Message-ID: <51FFF0A7.2040402@redhat.com>
Date: Mon, 05 Aug 2013 14:36:23 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 6/9] mm: zone_reclaim: compaction: increase the high order
 pages in the watermarks
References: <1375459596-30061-1-git-send-email-aarcange@redhat.com> <1375459596-30061-7-git-send-email-aarcange@redhat.com>
In-Reply-To: <1375459596-30061-7-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Johannes Weiner <jweiner@redhat.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rafael Aquini <aquini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Hush Bensen <hush.bensen@gmail.com>

On 08/02/2013 12:06 PM, Andrea Arcangeli wrote:
> Prevent the scaling down to reduce the watermarks too much.
>
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Not super fond of the magic number, but I don't have a better idea...

Acked-by: Rik van Riel <riel@redhat.com>


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
