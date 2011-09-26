Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 5B32A9000BD
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 11:31:14 -0400 (EDT)
Message-ID: <4E809ABB.2020807@redhat.com>
Date: Mon, 26 Sep 2011 11:31:07 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm] limit direct reclaim for higher order allocations
References: <20110926095507.34a2c48c@annuminas.surriel.com> <20110926150212.GB11313@suse.de>
In-Reply-To: <20110926150212.GB11313@suse.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Johannes Weiner <hannes@cmpxchg.org>

On 09/26/2011 11:02 AM, Mel Gorman wrote:

> I don't have a proper patch prepared but I think it is a mistake for
> reclaim and compaction to be using different logic when deciding
> if action should be taken. Compaction uses compaction_suitable()
> and compaction_deferred() to decide whether it should compact or not
> and reclaim/compaction should share the same logic. I don't have a
> proper patch but the check would look something like;

Mel and I just hashed out the details on IRC.

I'm building a test kernel with the new logic now and will
post an updated patch if everything works as expected.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
