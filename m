Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 45D1E6B002D
	for <linux-mm@kvack.org>; Fri,  7 Oct 2011 16:07:15 -0400 (EDT)
Message-ID: <4E8F5BEA.3040502@redhat.com>
Date: Fri, 07 Oct 2011 16:07:06 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] mm: Abort reclaim/compaction if compaction can proceed
References: <1318000643-27996-1-git-send-email-mgorman@suse.de> <1318000643-27996-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1318000643-27996-3-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Johannes Weiner <hannes@cmpxchg.org>, akpm@linux-foundation.org, Josh Boyer <jwboyer@redhat.com>, aarcange@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 10/07/2011 11:17 AM, Mel Gorman wrote:
> If compaction can proceed, shrink_zones() stops doing any work but
> the callers still shrink_slab(), raises the priority and potentially
> sleeps.  This patch aborts direct reclaim/compaction entirely if
> compaction can proceed.
>
> Signed-off-by: Mel Gorman<mgorman@suse.de>

This patch makes sense to me, but I have not tested it like
the first one.

Mel, have you tested this patch?  Did you see any changed
behaviour vs. just the first patch?

Having said that, I'm pretty sure the patch is ok :)

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
