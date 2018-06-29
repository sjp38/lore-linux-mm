Return-Path: <linux-kernel-owner@vger.kernel.org>
Date: Fri, 29 Jun 2018 21:57:05 +0900 (KST)
Message-Id: <20180629.215705.881234148380578564.davem@davemloft.net>
Subject: Re: [PATCH v2] net, mm: account sock objects to kmemcg
From: David Miller <davem@davemloft.net>
In-Reply-To: <20180627221642.247448-1-shakeelb@google.com>
References: <20180627221642.247448-1-shakeelb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: linux-kernel-owner@vger.kernel.org
To: shakeelb@google.com
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov.dev@gmail.com, gthelen@google.com, guro@fb.com, edumazet@google.com, ktkhai@virtuozzo.com, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

From: Shakeel Butt <shakeelb@google.com>
Date: Wed, 27 Jun 2018 15:16:42 -0700

> Currently the kernel accounts the memory for network traffic through
> mem_cgroup_[un]charge_skmem() interface. However the memory accounted
> only includes the truesize of sk_buff which does not include the size of
> sock objects. In our production environment, with opt-out kmem
> accounting, the sock kmem caches (TCP[v6], UDP[v6], RAW[v6], UNIX) are
> among the top most charged kmem caches and consume a significant amount
> of memory which can not be left as system overhead. So, this patch
> converts the kmem caches of all sock objects to SLAB_ACCOUNT.
> 
> Signed-off-by: Shakeel Butt <shakeelb@google.com>
> Suggested-by: Eric Dumazet <edumazet@google.com>
> ---
> Changelog since v1:
> - Instead of specific sock kmem_caches, convert all sock kmem_caches to
>   use SLAB_ACCOUNT.

Applied, thank you.
