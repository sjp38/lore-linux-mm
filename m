Return-Path: <SRS0=q2Op=WO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 456ACC3A589
	for <linux-mm@archiver.kernel.org>; Sun, 18 Aug 2019 17:11:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E8852206BB
	for <linux-mm@archiver.kernel.org>; Sun, 18 Aug 2019 17:11:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="WaP2At1j"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E8852206BB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 719326B0007; Sun, 18 Aug 2019 13:11:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6C8B36B000A; Sun, 18 Aug 2019 13:11:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5DF0E6B000C; Sun, 18 Aug 2019 13:11:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0177.hostedemail.com [216.40.44.177])
	by kanga.kvack.org (Postfix) with ESMTP id 3DEEB6B0007
	for <linux-mm@kvack.org>; Sun, 18 Aug 2019 13:11:21 -0400 (EDT)
Received: from smtpin04.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id ECB1940C3
	for <linux-mm@kvack.org>; Sun, 18 Aug 2019 17:11:20 +0000 (UTC)
X-FDA: 75836189520.04.cub38_28ca21ae75f18
X-HE-Tag: cub38_28ca21ae75f18
X-Filterd-Recvd-Size: 7699
Received: from mail-lf1-f68.google.com (mail-lf1-f68.google.com [209.85.167.68])
	by imf37.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun, 18 Aug 2019 17:11:20 +0000 (UTC)
Received: by mail-lf1-f68.google.com with SMTP id j17so7294488lfp.3
        for <linux-mm@kvack.org>; Sun, 18 Aug 2019 10:11:20 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=V6FvERiRuE4rLuQDy++aasCyihyfrIMaJryO5yAItSc=;
        b=WaP2At1jKt4NxrD1VsQrzd1giDFI41AfH7P6xaW9RXZnzqsPAZZ6Ue8X8KA9EpcEBY
         b+XlCcNlPiLporU5VRDztzEeLPO6mPmHoQu0FOqE4iWYc2aYXBRKZH9deeS4CEBbnKg9
         gLcrtIxsU1loOW/7MGyS1HqGgpd0y/AQBMl+twOdtjBXuPlZkIYI7i/3bNGq0OVeh4m5
         AV0/NMHoCagcIZPsnhy7F3D92o7/yhD1IVNPws8S2o/Qc+1kWpODxYoPeug6b84VM+qO
         0oKWZYsBfn/TEzItuqqvSfQk9nPSk1qG7RWHwNhgJOu+7i22QisMNDzYadty71JhYRbF
         C9Fg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=V6FvERiRuE4rLuQDy++aasCyihyfrIMaJryO5yAItSc=;
        b=CVHfaaB+vq35K96xipcp4g6FUD0VCeYWvitkGgf2oQbcWQxhzcz6FjbHp6GXk/FRHa
         +JD2Vq0yccRMPXSFzHOUduu46FlbxMpvW7H1fhheV7XJZfOTXOqTKO4Ub+WXNZ0Xmr9q
         DDEJv6hEglGUxL6ylTeFiRkNTg0UZMXvbm1J7+l2KAiOHKfi3in3LbczUk5y1/22iZwD
         XZ8UQgxxZ3PnOAJWoWfoHF8cNUivXdkKrVv2+NT9Jw5kbiJMPlcCgUif7F8W6NWiH4tP
         NkFChesnSgqdoGgM9PZBFaPj9jbAyeKGVWpjcSNGf/kwlR6siA7y5EnY78yY9jpBNIHw
         za1w==
X-Gm-Message-State: APjAAAXdH8+HycruhJl0t+HVuxQQuO5SpegD2l9Ah53UNe7rQs3UV0ik
	nD50OeFQTEuDMCGr2ufISmnXVsW1Gno2N3DGzm8=
X-Google-Smtp-Source: APXvYqyt2uT9IQBITmUZ3yarf3cPCwRrJ7FHLCCA+xFqmKnzIw/DSMFfU1s3F/9E9Rdlr6qV2o2yLqT5Kbj7J8ppZc4=
X-Received: by 2002:a05:6512:146:: with SMTP id m6mr10104263lfo.90.1566148278628;
 Sun, 18 Aug 2019 10:11:18 -0700 (PDT)
MIME-Version: 1.0
References: <1566102294-14803-1-git-send-email-laoar.shao@gmail.com>
In-Reply-To: <1566102294-14803-1-git-send-email-laoar.shao@gmail.com>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Sun, 18 Aug 2019 22:41:06 +0530
Message-ID: <CAFqt6zZOeoK0s6gP_-me1fJ_ymRN=QXj3mfKXNQ-i5_coK21iQ@mail.gmail.com>
Subject: Re: [PATCH] mm, memcg: skip killing processes under memcg protection
 at first scan
To: Yafang Shao <laoar.shao@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, 
	Roman Gushchin <guro@fb.com>, Randy Dunlap <rdunlap@infradead.org>, 
	Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, 
	Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Aug 18, 2019 at 9:55 AM Yafang Shao <laoar.shao@gmail.com> wrote:
>
> In the current memory.min design, the system is going to do OOM instead
> of reclaiming the reclaimable pages protected by memory.min if the
> system is lack of free memory. While under this condition, the OOM
> killer may kill the processes in the memcg protected by memory.min.
> This behavior is very weird.
> In order to make it more reasonable, I make some changes in the OOM
> killer. In this patch, the OOM killer will do two-round scan. It will
> skip the processes under memcg protection at the first scan, and if it
> can't kill any processes it will rescan all the processes.
>
> Regarding the overhead this change may takes, I don't think it will be a
> problem because this only happens under system  memory pressure and
> the OOM killer can't find any proper victims which are not under memcg
> protection.
>
> Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
> Cc: Roman Gushchin <guro@fb.com>
> Cc: Randy Dunlap <rdunlap@infradead.org>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> ---
>  include/linux/memcontrol.h |  6 ++++++
>  mm/memcontrol.c            | 16 ++++++++++++++++
>  mm/oom_kill.c              | 23 +++++++++++++++++++++--
>  3 files changed, 43 insertions(+), 2 deletions(-)
>
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 44c4146..58bd86b 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -337,6 +337,7 @@ static inline bool mem_cgroup_disabled(void)
>
>  enum mem_cgroup_protection mem_cgroup_protected(struct mem_cgroup *root,
>                                                 struct mem_cgroup *memcg);
> +int task_under_memcg_protection(struct task_struct *p);
>
>  int mem_cgroup_try_charge(struct page *page, struct mm_struct *mm,
>                           gfp_t gfp_mask, struct mem_cgroup **memcgp,
> @@ -813,6 +814,11 @@ static inline enum mem_cgroup_protection mem_cgroup_protected(
>         return MEMCG_PROT_NONE;
>  }
>
> +int task_under_memcg_protection(struct task_struct *p)
> +{
> +       return 0;
> +}
> +
>  static inline int mem_cgroup_try_charge(struct page *page, struct mm_struct *mm,
>                                         gfp_t gfp_mask,
>                                         struct mem_cgroup **memcgp,
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index cdbb7a8..c4d8e53 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -6030,6 +6030,22 @@ enum mem_cgroup_protection mem_cgroup_protected(struct mem_cgroup *root,
>                 return MEMCG_PROT_NONE;
>  }
>
> +int task_under_memcg_protection(struct task_struct *p)
> +{
> +       struct mem_cgroup *memcg;
> +       int protected;
> +
> +       rcu_read_lock();
> +       memcg = mem_cgroup_from_task(p);
> +       if (memcg != root_mem_cgroup && memcg->memory.min)
> +               protected = 1;
> +       else
> +               protected = 0;
> +       rcu_read_unlock();
> +
> +       return protected;

I think returning a bool type would be more appropriate.

> +}
> +
>  /**
>   * mem_cgroup_try_charge - try charging a page
>   * @page: page to charge
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index eda2e2a..259dd2c 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -368,11 +368,30 @@ static void select_bad_process(struct oom_control *oc)
>                 mem_cgroup_scan_tasks(oc->memcg, oom_evaluate_task, oc);
>         else {
>                 struct task_struct *p;
> +               int memcg_check = 0;
> +               int memcg_skip = 0;
> +               int selected = 0;
>
>                 rcu_read_lock();
> -               for_each_process(p)
> -                       if (oom_evaluate_task(p, oc))
> +retry:
> +               for_each_process(p) {
> +                       if (!memcg_check && task_under_memcg_protection(p)) {
> +                               memcg_skip = 1;
> +                               continue;
> +                       }
> +                       selected = oom_evaluate_task(p, oc);
> +                       if (selected)
>                                 break;
> +               }
> +
> +               if (!selected) {
> +                       if (memcg_skip) {
> +                               if (!oc->chosen || oc->chosen == (void *)-1UL) {
> +                                       memcg_check = 1;
> +                                       goto retry;
> +                               }
> +                       }
> +               }
>                 rcu_read_unlock();
>         }
>  }
> --
> 1.8.3.1
>
>

