Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7C1B56B0269
	for <linux-mm@kvack.org>; Thu, 28 Jun 2018 11:03:44 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id s16-v6so2518757pgq.4
        for <linux-mm@kvack.org>; Thu, 28 Jun 2018 08:03:44 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l17-v6sor1636435pfi.108.2018.06.28.08.03.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Jun 2018 08:03:43 -0700 (PDT)
Subject: Re: [PATCH v2] net, mm: account sock objects to kmemcg
References: <20180627221642.247448-1-shakeelb@google.com>
From: Eric Dumazet <eric.dumazet@gmail.com>
Message-ID: <b2bf72da-4980-1aae-0187-cc9353801586@gmail.com>
Date: Thu, 28 Jun 2018 08:03:40 -0700
MIME-Version: 1.0
In-Reply-To: <20180627221642.247448-1-shakeelb@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Greg Thelen <gthelen@google.com>, Roman Gushchin <guro@fb.com>, "David S . Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@google.com>, Kirill Tkhai <ktkhai@virtuozzo.com>, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org



On 06/27/2018 03:16 PM, Shakeel Butt wrote:
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

Reviewed-by: Eric Dumazet <edumazet@google.com>

Thanks !
