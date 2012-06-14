Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id DFF976B005C
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 03:07:09 -0400 (EDT)
Message-ID: <4FD98D9F.9050602@kernel.org>
Date: Thu, 14 Jun 2012 16:07:11 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/compaction: cleanup on compaction_deferred
References: <1339636753-12519-1-git-send-email-shangw@linux.vnet.ibm.com>
In-Reply-To: <1339636753-12519-1-git-send-email-shangw@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gavin Shan <shangw@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, akpm@linux-foundation.org, Mel Gorman <mgorman@suse.de>

On 06/14/2012 10:19 AM, Gavin Shan wrote:

> When CONFIG_COMPACTION is enabled, compaction_deferred() tries
> to recalculate the deferred limit again, which isn't necessary.
> 
> When CONFIG_COMPACTION is disabled, compaction_deferred() should
> return "true" or "false" since it has "bool" for its return value.
> 
> Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>


Acked-by: Minchan Kim <minchan@kernel.org>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
