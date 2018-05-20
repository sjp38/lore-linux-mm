Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2C6BF6B06EF
	for <linux-mm@kvack.org>; Sun, 20 May 2018 03:57:27 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id p124-v6so142735lfp.22
        for <linux-mm@kvack.org>; Sun, 20 May 2018 00:57:27 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l188-v6sor371403lfb.69.2018.05.20.00.57.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 20 May 2018 00:57:25 -0700 (PDT)
Date: Sun, 20 May 2018 10:57:22 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH v6 13/17] mm: Export mem_cgroup_is_root()
Message-ID: <20180520075722.qwwrxuz52kqulsnw@esperanza>
References: <152663268383.5308.8660992135988724014.stgit@localhost.localdomain>
 <152663303322.5308.13190345531934617119.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <152663303322.5308.13190345531934617119.stgit@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: akpm@linux-foundation.org, shakeelb@google.com, viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org, lirongqing@baidu.com, aryabinin@virtuozzo.com

On Fri, May 18, 2018 at 11:43:53AM +0300, Kirill Tkhai wrote:
> This will be used in next patch.
> 
> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
> ---
>  include/linux/memcontrol.h |   10 ++++++++++
>  mm/memcontrol.c            |    5 -----
>  2 files changed, 10 insertions(+), 5 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 7ae1b94becf3..cd44c1fac22b 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -311,6 +311,11 @@ struct mem_cgroup {
>  
>  extern struct mem_cgroup *root_mem_cgroup;
>  
> +static inline bool mem_cgroup_is_root(struct mem_cgroup *memcg)
> +{
> +	return (memcg == root_mem_cgroup);
> +}
> +
>  static inline bool mem_cgroup_disabled(void)
>  {
>  	return !cgroup_subsys_enabled(memory_cgrp_subsys);
> @@ -780,6 +785,11 @@ void mem_cgroup_split_huge_fixup(struct page *head);
>  
>  struct mem_cgroup;
>  
> +static inline bool mem_cgroup_is_root(struct mem_cgroup *memcg)
> +{
> +	return false;
> +}
> +

This stub must return true as one can think of !MEMCG as of the case
when there's the only cgroup - the root.
