Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 9DA126B0087
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 19:49:33 -0500 (EST)
Message-ID: <4D00277F.9040000@redhat.com>
Date: Wed, 08 Dec 2010 19:49:03 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch] mm: skip rebalance of hopeless zones
References: <1291821419-11213-1-git-send-email-hannes@cmpxchg.org> <20101209003621.GB3796@hostway.ca>
In-Reply-To: <20101209003621.GB3796@hostway.ca>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Simon Kirby <sim@hostway.ca>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 12/08/2010 07:36 PM, Simon Kirby wrote:

> Mel Gorman posted a similar patch to yours, but the logic is instead to
> consider order>0 balancing sufficient when there are other balanced zones
> totalling at least 25% of pages on this node.  This would probably fix
> your case as well.

Mel's patch addresses something very different and is unlikely
to fix the problem this patch addresses.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
