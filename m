Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id DC37D8D003C
	for <linux-mm@kvack.org>; Tue,  1 Mar 2011 03:16:02 -0500 (EST)
Date: Tue, 01 Mar 2011 00:16:38 -0800 (PST)
Message-Id: <20110301.001638.104075130.davem@davemloft.net>
Subject: Re: [PATCH 4/4] net,rcu: don't assume the size of struct rcu_head
From: David Miller <davem@davemloft.net>
In-Reply-To: <4D6CA860.3020409@cn.fujitsu.com>
References: <4D6CA860.3020409@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: laijs@cn.fujitsu.com
Cc: mingo@elte.hu, paulmck@linux.vnet.ibm.com, cl@linux-foundation.org, penberg@kernel.org, eric.dumazet@gmail.com, mpm@selenic.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org

From: Lai Jiangshan <laijs@cn.fujitsu.com>
Date: Tue, 01 Mar 2011 16:03:44 +0800

> 
> struct dst_entry assumes the size of struct rcu_head as 2 * sizeof(long)
> and manually adds pads for aligning for "__refcnt".
> 
> When the size of struct rcu_head is changed, these manual padding
> is wrong. Use __attribute__((aligned (64))) instead.
> 
> Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>

We don't want to use the align if it's going to waste lots of space.

Instead we want to rearrange the structure so that the alignment comes
more cheaply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
