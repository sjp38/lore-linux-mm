Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 27E5F8D0039
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 13:25:46 -0500 (EST)
Date: Tue, 8 Mar 2011 12:25:41 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/4] slub,rcu: don't assume the size of struct rcu_head
In-Reply-To: <4D6CA852.3060303@cn.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1103081224550.25214@router.home>
References: <4D6CA852.3060303@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lai Jiangshan <laijs@cn.fujitsu.com>
Cc: Ingo Molnar <mingo@elte.hu>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>, "David S. Miller" <davem@davemloft.net>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org

On Tue, 1 Mar 2011, Lai Jiangshan wrote:

> -		 * RCU free overloads the RCU head over the LRU
> -		 */
> -		struct rcu_head *head = (void *)&page->lru;
> +		struct rcu_head *head;
> +
> +		if (need_reserve_slab_rcu) {
> +			int order = compound_order(page);
> +			int offset = (PAGE_SIZE << order) - s->reserved;
> +
> +			BUG_ON(s->reserved != sizeof(*head));

VM_BUG_ON is sufficient here I think.

Otherwise

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
