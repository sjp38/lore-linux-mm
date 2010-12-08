Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 486736B0087
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 13:06:06 -0500 (EST)
Message-ID: <4CFFC907.4090806@redhat.com>
Date: Wed, 08 Dec 2010 13:05:59 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch] mm: skip rebalance of hopeless zones
References: <1291821419-11213-1-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1291821419-11213-1-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 12/08/2010 10:16 AM, Johannes Weiner wrote:
> Kswapd tries to rebalance zones persistently until their high
> watermarks are restored.
>
> If the amount of unreclaimable pages in a zone makes this impossible
> for reclaim, though, kswapd will end up in a busy loop without a
> chance of reaching its goal.
>
> This behaviour was observed on a virtual machine with a tiny
> Normal-zone that filled up with unreclaimable slab objects.
>
> This patch makes kswapd skip rebalancing on such 'hopeless' zones and
> leaves them to direct reclaim.
>
> Signed-off-by: Johannes Weiner<hannes@cmpxchg.org>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
