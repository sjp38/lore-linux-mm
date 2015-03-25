Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 11CF16B0038
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 04:07:37 -0400 (EDT)
Received: by pdbop1 with SMTP id op1so20708542pdb.2
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 01:07:36 -0700 (PDT)
Received: from us-alimail-mta1.hst.scl.en.alidc.net (mail113-248.mail.alibaba.com. [205.204.113.248])
        by mx.google.com with ESMTP id vy7si2529445pac.53.2015.03.25.01.07.34
        for <linux-mm@kvack.org>;
        Wed, 25 Mar 2015 01:07:36 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <048301d066d1$653e63d0$2fbb2b70$@alibaba-inc.com>
In-Reply-To: <048301d066d1$653e63d0$2fbb2b70$@alibaba-inc.com>
Subject: Re: [patch 06/12] mm: oom_kill: simplify OOM killer locking
Date: Wed, 25 Mar 2015 16:05:57 +0800
Message-ID: <048701d066d2$86b182d0$94148870$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Hillf Danton <hillf.zj@alibaba-inc.com>


> --- a/include/linux/oom.h
> +++ b/include/linux/oom.h
> @@ -32,6 +32,8 @@ enum oom_scan_t {
>  /* Thread is the potential origin of an oom condition; kill first on oom */
>  #define OOM_FLAG_ORIGIN		((__force oom_flags_t)0x1)
> 
> +extern struct mutex oom_lock;
> +
>  static inline void set_current_oom_origin(void)
>  {
>  	current->signal->oom_flags |= OOM_FLAG_ORIGIN;
> @@ -60,9 +62,6 @@ extern void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
>  			     struct mem_cgroup *memcg, nodemask_t *nodemask,
>  			     const char *message);
> 
> -extern bool oom_zonelist_trylock(struct zonelist *zonelist, gfp_t gfp_flags);
> -extern void oom_zonelist_unlock(struct zonelist *zonelist, gfp_t gfp_flags);
Alternately expose three functions, rather than oom_lock mutex?
bool oom_trylock(void);
void oom_lock(void);
void oom_unlock(void);

Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
