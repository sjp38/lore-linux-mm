Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 595386B004D
	for <linux-mm@kvack.org>; Mon, 28 Nov 2011 18:08:17 -0500 (EST)
Date: Mon, 28 Nov 2011 18:08:07 -0500 (EST)
Message-Id: <20111128.180807.649757269111867027.davem@davemloft.net>
Subject: Re: [PATCH] net: Fix corruption in /proc/*/net/dev_mcast
From: David Miller <davem@davemloft.net>
In-Reply-To: <1322474116.2292.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1321870529.2552.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<20111128181446.2ab784d0@kryten>
	<1322474116.2292.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: eric.dumazet@gmail.com
Cc: anton@samba.org, levinsasha928@gmail.com, mpm@selenic.com, cl@linux-foundation.org, penberg@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, mihai.maruseac@gmail.com

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 28 Nov 2011 10:55:16 +0100

>> With slub debugging on I see red zone issues in /proc/*/net/dev_mcast:
>> 
>> =============================================================================
>> BUG kmalloc-8: Redzone overwritten
>> -----------------------------------------------------------------------------
 ...
>> dev_mc_seq_ops uses dev_seq_start/next/stop but only allocates
>> sizeof(struct seq_net_private) of private data, whereas it expects
>> sizeof(struct dev_iter_state):
>> 
>> struct dev_iter_state {
>> 	struct seq_net_private p;
>> 	unsigned int pos; /* bucket << BUCKET_SPACE + offset */
>> };
>> 
>> Create dev_seq_open_ops and use it so we don't have to expose
>> struct dev_iter_state.
>> 
>> Signed-off-by: Anton Blanchard <anton@samba.org>
 ...
> Problem added by commit f04565ddf52e4 (dev: use name hash for
> dev_seq_ops)
> 
> 
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Mihai Maruseac <mihai.maruseac@gmail.com>

Applied, thanks everyone.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
