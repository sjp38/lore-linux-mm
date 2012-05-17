Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 69D9E6B00E7
	for <linux-mm@kvack.org>; Thu, 17 May 2012 16:13:22 -0400 (EDT)
Date: Thu, 17 May 2012 16:13:16 -0400 (EDT)
Message-Id: <20120517.161316.302543932768181836.davem@davemloft.net>
Subject: Re: [PATCH 13/17] netvm: Set PF_MEMALLOC as appropriate during SKB
 processing
From: David Miller <davem@davemloft.net>
In-Reply-To: <1337266231-8031-14-git-send-email-mgorman@suse.de>
References: <1337266231-8031-1-git-send-email-mgorman@suse.de>
	<1337266231-8031-14-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mgorman@suse.de
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, neilb@suse.de, a.p.zijlstra@chello.nl, michaelc@cs.wisc.edu, emunson@mgebm.net

From: Mel Gorman <mgorman@suse.de>
Date: Thu, 17 May 2012 15:50:27 +0100

> In order to make sure pfmemalloc packets receive all memory
> needed to proceed, ensure processing of pfmemalloc SKBs happens
> under PF_MEMALLOC. This is limited to a subset of protocols that
> are expected to be used for writing to swap. Taps are not allowed to
> use PF_MEMALLOC as these are expected to communicate with userspace
> processes which could be paged out.
> 
> [a.p.zijlstra@chello.nl: Ideas taken from various patches]
> [jslaby@suse.cz: Lock imbalance fix]
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Acked-by: David S. Miller <davem@davemloft.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
