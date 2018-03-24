Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id ECD476B0026
	for <linux-mm@kvack.org>; Sat, 24 Mar 2018 15:32:57 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id g6-v6so4900984lfg.14
        for <linux-mm@kvack.org>; Sat, 24 Mar 2018 12:32:57 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s81sor2899280lje.32.2018.03.24.12.32.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 24 Mar 2018 12:32:56 -0700 (PDT)
Date: Sat, 24 Mar 2018 22:32:53 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH 06/10] list_lru: Pass dst_memcg argument to
 memcg_drain_list_lru_node()
Message-ID: <20180324193253.y653nm4z6sh7u2kd@esperanza>
References: <152163840790.21546.980703278415599202.stgit@localhost.localdomain>
 <152163853059.21546.940468208501917585.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <152163853059.21546.940468208501917585.stgit@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, akpm@linux-foundation.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, hillf.zj@alibaba-inc.com, ying.huang@intel.com, mgorman@techsingularity.net, shakeelb@google.com, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org

On Wed, Mar 21, 2018 at 04:22:10PM +0300, Kirill Tkhai wrote:
> This is just refactoring to allow next patches to have
> dst_memcg pointer in memcg_drain_list_lru_node().
> 
> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
> ---
>  include/linux/list_lru.h |    2 +-
>  mm/list_lru.c            |   11 ++++++-----
>  mm/memcontrol.c          |    2 +-
>  3 files changed, 8 insertions(+), 7 deletions(-)
> 
> diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
> index ce1d010cd3fa..50cf8c61c609 100644
> --- a/include/linux/list_lru.h
> +++ b/include/linux/list_lru.h
> @@ -66,7 +66,7 @@ int __list_lru_init(struct list_lru *lru, bool memcg_aware,
>  #define list_lru_init_memcg(lru)	__list_lru_init((lru), true, NULL)
>  
>  int memcg_update_all_list_lrus(int num_memcgs);
> -void memcg_drain_all_list_lrus(int src_idx, int dst_idx);
> +void memcg_drain_all_list_lrus(int src_idx, struct mem_cgroup *dst_memcg);

Please, for consistency pass the source cgroup as a pointer as well.
