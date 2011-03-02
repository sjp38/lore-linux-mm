Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 490C98D0039
	for <linux-mm@kvack.org>; Tue,  1 Mar 2011 21:54:48 -0500 (EST)
Message-ID: <4D6DB1BD.60003@cn.fujitsu.com>
Date: Wed, 02 Mar 2011 10:55:57 +0800
From: Lai Jiangshan <laijs@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/4] slub,rcu: don't assume the size of struct rcu_head
References: <4D6CA852.3060303@cn.fujitsu.com> <AANLkTimXy2Yaj+NTDMNTWuLqHHfKZJhVDpeXj3CfMvBf@mail.gmail.com> <alpine.DEB.2.00.1103010909320.6253@router.home>
In-Reply-To: <alpine.DEB.2.00.1103010909320.6253@router.home>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Ingo Molnar <mingo@elte.hu>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Eric Dumazet <eric.dumazet@gmail.com>, "David S. Miller" <davem@davemloft.net>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org

On 03/01/2011 11:11 PM, Christoph Lameter wrote:
> On Tue, 1 Mar 2011, Pekka Enberg wrote:
> 
>> The SLAB and SLUB patches are fine by me if there are going to be real
>> users for this. Christoph, Paul?
> 
> The solution is a bit overkill. It would be much simpler to add a union to
> struct page that has lru and the rcu in there similar things can be done
> for SLAB and the network layer. A similar issue already exists for the
> spinlock in struct page. Lets follow the existing way of handling this.

I don't want to impact the whole system too much to
touch struct page. The solution changes existed things little,
and the reversed data may just make use of the pad data.

> 
> Struct page may be larger for debugging purposes already because of the
> need for extended spinlock data.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
