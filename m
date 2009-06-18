Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id CECAC6B0055
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 23:13:37 -0400 (EDT)
Message-ID: <4A39B0D3.60301@kernel.org>
Date: Thu, 18 Jun 2009 12:13:23 +0900
From: Tejun Heo <tj@kernel.org>
MIME-Version: 1.0
Subject: Re: [this_cpu_xx V2 17/19] Move early initialization of pagesets
 out of zone_wait_table_init()
References: <20090617203337.399182817@gentwo.org> <20090617203446.090278229@gentwo.org>
In-Reply-To: <20090617203446.090278229@gentwo.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: cl@linux-foundation.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, mingo@elte.hu, rusty@rustcorp.com.au, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

cl@linux-foundation.org wrote:
> Explicitly initialize the pagesets after the per cpu areas have been
> initialized. This is necessary in order to be able to use per cpu
> operations in later patches.
> 
> Cc: Mel Gorman <mel@csn.ul.ie>
> Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

For 17-19, not being too familiar with the code, I can't ack them but
at a glance they look really nice to me.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
