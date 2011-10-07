Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 9EE636B002D
	for <linux-mm@kvack.org>; Fri,  7 Oct 2011 15:32:39 -0400 (EDT)
Message-ID: <4E8F53CD.9000609@redhat.com>
Date: Fri, 07 Oct 2011 15:32:29 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] mm: vmscan: Limit direct reclaim for higher order
 allocations
References: <1318000643-27996-1-git-send-email-mgorman@suse.de> <1318000643-27996-2-git-send-email-mgorman@suse.de>
In-Reply-To: <1318000643-27996-2-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Johannes Weiner <hannes@cmpxchg.org>, akpm@linux-foundation.org, Josh Boyer <jwboyer@redhat.com>, aarcange@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 10/07/2011 11:17 AM, Mel Gorman wrote:
> From: Rik van Riel<riel@redhat.com>
>
> When suffering from memory fragmentation due to unfreeable pages,
> THP page faults will repeatedly try to compact memory.  Due to the
> unfreeable pages, compaction fails.

I believe Andrew just merged this one :)

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
