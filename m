Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id CC4D48D003B
	for <linux-mm@kvack.org>; Wed, 18 May 2011 02:09:33 -0400 (EDT)
Message-ID: <4DD36299.8000108@cs.helsinki.fi>
Date: Wed, 18 May 2011 09:09:29 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH 2/4] mm: slub: Do not wake kswapd for SLUBs speculative
 high-order allocations
References: <1305295404-12129-1-git-send-email-mgorman@suse.de> <1305295404-12129-3-git-send-email-mgorman@suse.de> <alpine.DEB.2.00.1105161410090.4353@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1105161410090.4353@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, James Bottomley <James.Bottomley@hansenpartnership.com>, Colin King <colin.king@canonical.com>, Raghavendra D Prabhu <raghu.prabhu13@gmail.com>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>

On 5/17/11 12:10 AM, David Rientjes wrote:
> On Fri, 13 May 2011, Mel Gorman wrote:
>
>> To avoid locking and per-cpu overhead, SLUB optimisically uses
>> high-order allocations and falls back to lower allocations if they
>> fail.  However, by simply trying to allocate, kswapd is woken up to
>> start reclaiming at that order. On a desktop system, two users report
>> that the system is getting locked up with kswapd using large amounts
>> of CPU.  Using SLAB instead of SLUB made this problem go away.
>>
>> This patch prevents kswapd being woken up for high-order allocations.
>> Testing indicated that with this patch applied, the system was much
>> harder to hang and even when it did, it eventually recovered.
>>
>> Signed-off-by: Mel Gorman<mgorman@suse.de>
> Acked-by: David Rientjes<rientjes@google.com>

Christoph? I think this patch is sane although the original rationale 
was to workaround kswapd problems.

                 Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
