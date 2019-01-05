Return-Path: <SRS0=AeVH=PN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9F2CCC43612
	for <linux-mm@archiver.kernel.org>; Sat,  5 Jan 2019 00:47:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 479F8218DE
	for <linux-mm@archiver.kernel.org>; Sat,  5 Jan 2019 00:47:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="odegTTO5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 479F8218DE
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B00E88E0116; Fri,  4 Jan 2019 19:47:57 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A88F28E00F9; Fri,  4 Jan 2019 19:47:57 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 954878E0116; Fri,  4 Jan 2019 19:47:57 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 61E6A8E00F9
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 19:47:57 -0500 (EST)
Received: by mail-yw1-f71.google.com with SMTP id b8so24391948ywb.17
        for <linux-mm@kvack.org>; Fri, 04 Jan 2019 16:47:57 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=ZyHJGaj0o+e27UnST3Gc5WJRZ2smur2QRsLhOjYwUTA=;
        b=Fd0+3xH25bLgn49ivKUhPVNjgan0hHxaYLxSLB2xi8W7E8InN/4sMwfPhPoB8FT956
         0YGSoXjO5155SSV/vUhnbxqEMzLpj77L1W8h5cy2LpyIQRLnj3CGvnRCFJjdFTvvbl4w
         5D9NSQtWJRQsJOAieZAYoS279vtsCkreKw8/yZtn8YHk73RUQQ+05XGz6ziAlNnrUo2T
         E3+I34/s2yLsndbzWDIgjVcRSkxx+uBzf+gXRfoKIiOZe+eTN33sPi30RDztGeGieZ4A
         k5NeYNBTTRaiqJ8akMIesSKxG6Q9xeqsUEhKWo/cyx5OhFpI/XXPIX6pUK7PKxWih0rJ
         ZcMA==
X-Gm-Message-State: AA+aEWYKC3EV5CZOw9rjl6TG8C1NXNcY09s2tgifCEKr/IP8SgvRZH9O
	xVCHQnd+4DgpTz2cW/B1i4+o1O6E9fUPyDuxJ2IpTiFhJ147vgVYRm2RYTcWcs+5N5tR99fENSN
	qOeEbmUSbFQgGBOr8fH3WmX82sfv0IUcT51X6QcCrTTTtw+Y0PNlHKxZeyrI5yM8Lc4iSnfNveq
	2kKnnoWQ8t5rZq4R7+hiuu1BThYH029Nea8+hzgd5MS6/KQpnr8UzPpsMS94cOa0oUByYciFr0z
	+Dtm+5qzxrTV27JNwiQ+V+gGRd5n6FB/15jIEt9Cj6xfWC1okqG/nvfWZHEEyW//UBzR8mj+Dxh
	l9XICWPWQad+1t5Qgt5GnqRqK6YKcGNIqj/3VJXuOIHK9kkjGLeqB4xUSgNBwEh3Fs3LjulznTG
	F
X-Received: by 2002:a81:c5:: with SMTP id 188mr53127352ywa.327.1546649277071;
        Fri, 04 Jan 2019 16:47:57 -0800 (PST)
X-Received: by 2002:a81:c5:: with SMTP id 188mr53127338ywa.327.1546649276351;
        Fri, 04 Jan 2019 16:47:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546649276; cv=none;
        d=google.com; s=arc-20160816;
        b=1EsuQgMm48I9wc+P5YwBaEZUBNFXFok6svfDQpskJ0Vd+lEgXA55fIrP0Bi04BzrT1
         UC11yr9XtQsK8T/HDPEvZqb3dv3rgWLHp+96u0VsrScv4QrPQK4gZEkpZJUZDD0qfjXT
         U1DDZGZspvzqGbtJfTpMpJiUrBM5lYdq0EW7JUbUjt4G7PyyOAoWGu0x6ZmyAQsBZB7K
         3XmOCMkdAf5iDwxyl3HcG0mqpvnFY0FDdUZeN+YWPBA6HJV/FfUoGvbXcgH5HjLOoixo
         NayyvERRkkuvsYOhVxvCIQRdbPEhMr/o5j/9xLs0lEkamCUubB3axXF4Hemn2vAXx+rV
         ZC8Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=ZyHJGaj0o+e27UnST3Gc5WJRZ2smur2QRsLhOjYwUTA=;
        b=mm2UM8y7/hYBe4JgcW6j4zX24t3YlRsUTLsy7YAPs4mWSIBpFBfVMkNjamRO5s1OBK
         XN3/EVy/pG3izaHwc6nH+kYMcFQq3qGA4TtRm1uqMLQGUX35VLQ9ZMQRX3zNwySpS5Zn
         8y2ZQOAlOsH0ffAYGnzeS/Va1O6ios3YAtUrhj21lrAh40LU6fQkQoUyZY4NeWsT00ay
         rr9/66Fh9sAwuvt9D4WkhINVUVsqibEhmv0a6l0Z5RLGM8TG5SpEiTmt3tPGxk+g/QKD
         tBRFaG1HNZPdE9XvhfrI7jbwLLWNu+s6SPOfjuMfc4klfTWkP6CvSMaIzx8vqoX3pMn6
         TvqA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=odegTTO5;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l65sor15078676ybl.105.2019.01.04.16.47.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 04 Jan 2019 16:47:56 -0800 (PST)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=odegTTO5;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=ZyHJGaj0o+e27UnST3Gc5WJRZ2smur2QRsLhOjYwUTA=;
        b=odegTTO5L3tLhgD1pTSIn+axOi6LLINJHUTowFwpbsXmgGh5aA2AI2kMlojrr39Lzn
         zSsjvpYS9+a/2T/3JBtK3Av1O+jKaaATel/du/rojEhS6dQMUEqcKJP6bIF3qpBrHhni
         jpqDJM021XcVxKKBUMBBeC0x83FDnGQWF9z32ANjoy7E9ni55gnFK4FqEy3hSyOwunsF
         ch4pFlM+BG0Fac7L5pglVwYmUTsohOway4mj+wG8ko8m48KQRBNfJpYha2ZnqmtwoeSV
         4kGIj4wKg6TwZIo3e2L/OPQSYYZSOITf5RSO4mxzkWNtUdLxmJhrVnO+ZvUif/mJyFZo
         sdTw==
X-Google-Smtp-Source: ALg8bN671BeMyGFWenOeeKnzpzD5OPH9AKzrdoY9n0PLlkRXd6MtMp98kQ6arNqmV5IudASwyzzZfBRyUW+3f7pBkGo=
X-Received: by 2002:a25:9247:: with SMTP id e7mr42417407ybo.496.1546649275027;
 Fri, 04 Jan 2019 16:47:55 -0800 (PST)
MIME-Version: 1.0
References: <1546647560-40026-1-git-send-email-yang.shi@linux.alibaba.com> <1546647560-40026-4-git-send-email-yang.shi@linux.alibaba.com>
In-Reply-To: <1546647560-40026-4-git-send-email-yang.shi@linux.alibaba.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Fri, 4 Jan 2019 16:47:44 -0800
Message-ID:
 <CALvZod4ea4fR2n1EdZ3HwB3O3iWDHw5nXRnPLKbR6mAuDkWuQA@mail.gmail.com>
Subject: Re: [v2 PATCH 3/5] mm: memcontrol: introduce wipe_on_offline interface
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, 
	Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190105004744.0uuvsLzW32m8wcYO9hwGttuBRa7HFhodozPGwzKmcZo@z>

On Fri, Jan 4, 2019 at 4:21 PM Yang Shi <yang.shi@linux.alibaba.com> wrote:
>
> We have some usecases which create and remove memcgs very frequently,
> and the tasks in the memcg may just access the files which are unlikely
> accessed by anyone else.  So, we prefer force_empty the memcg before
> rmdir'ing it to reclaim the page cache so that they don't get
> accumulated to incur unnecessary memory pressure.  Since the memory
> pressure may incur direct reclaim to harm some latency sensitive
> applications.
>
> Force empty would help out such usecase, however force empty reclaims
> memory synchronously when writing to memory.force_empty.  It may take
> some time to return and the afterwards operations are blocked by it.
> Although this can be done in background, some usecases may need create
> new memcg with the same name right after the old one is deleted.  So,
> the creation might get blocked by the before reclaim/remove operation.
>
> Delaying memory reclaim in cgroup offline for such usecase sounds
> reasonable.  Introduced a new interface, called wipe_on_offline for both
> default and legacy hierarchy, which does memory reclaim in css offline
> kworker.
>
> Writing to 1 would enable it, writing 0 would disable it.
>
> Suggested-by: Michal Hocko <mhocko@suse.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> ---
>  include/linux/memcontrol.h |  3 +++
>  mm/memcontrol.c            | 49 ++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 52 insertions(+)
>
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 83ae11c..2f1258a 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -311,6 +311,9 @@ struct mem_cgroup {
>         struct list_head event_list;
>         spinlock_t event_list_lock;
>
> +       /* Reclaim as much as possible memory in offline kworker */
> +       bool wipe_on_offline;
> +
>         struct mem_cgroup_per_node *nodeinfo[0];
>         /* WARNING: nodeinfo must be the last member here */
>  };
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 75208a2..5a13c6b 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2918,6 +2918,35 @@ static ssize_t mem_cgroup_force_empty_write(struct kernfs_open_file *of,
>         return mem_cgroup_force_empty(memcg) ?: nbytes;
>  }
>
> +static int wipe_on_offline_show(struct seq_file *m, void *v)
> +{
> +       struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
> +
> +       seq_printf(m, "%lu\n", (unsigned long)memcg->wipe_on_offline);
> +
> +       return 0;
> +}
> +
> +static int wipe_on_offline_write(struct cgroup_subsys_state *css,
> +                                struct cftype *cft, u64 val)
> +{
> +       int ret = 0;
> +
> +       struct mem_cgroup *memcg = mem_cgroup_from_css(css);
> +
> +       if (mem_cgroup_is_root(memcg))
> +               return -EINVAL;
> +
> +       if (val == 0)
> +               memcg->wipe_on_offline = false;
> +       else if (val == 1)
> +               memcg->wipe_on_offline = true;
> +       else
> +               ret = -EINVAL;
> +
> +       return ret;
> +}
> +
>  static u64 mem_cgroup_hierarchy_read(struct cgroup_subsys_state *css,
>                                      struct cftype *cft)
>  {
> @@ -4283,6 +4312,11 @@ static ssize_t memcg_write_event_control(struct kernfs_open_file *of,
>                 .write = mem_cgroup_reset,
>                 .read_u64 = mem_cgroup_read_u64,
>         },
> +       {
> +               .name = "wipe_on_offline",

What about "force_empty_on_offline"?

> +               .seq_show = wipe_on_offline_show,
> +               .write_u64 = wipe_on_offline_write,
> +       },
>         { },    /* terminate */
>  };
>
> @@ -4569,6 +4603,15 @@ static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
>         page_counter_set_min(&memcg->memory, 0);
>         page_counter_set_low(&memcg->memory, 0);
>
> +       /*
> +        * Reclaim as much as possible memory when offlining.
> +        *
> +        * Do it after min/low is reset otherwise some memory might
> +        * be protected by min/low.
> +        */
> +       if (memcg->wipe_on_offline)
> +               mem_cgroup_force_empty(memcg);
> +

mem_cgroup_force_empty() also does drain_all_stock(), so, move
drain_all_stock() in mem_cgroup_css_offline() to the else of 'if
(memcg->wipe_on_offline)'.

>         memcg_offline_kmem(memcg);
>         wb_memcg_offline(memcg);
>
> @@ -5694,6 +5737,12 @@ static ssize_t memory_oom_group_write(struct kernfs_open_file *of,
>                 .seq_show = memory_oom_group_show,
>                 .write = memory_oom_group_write,
>         },
> +       {
> +               .name = "wipe_on_offline",
> +               .flags = CFTYPE_NOT_ON_ROOT,
> +               .seq_show = wipe_on_offline_show,
> +               .write_u64 = wipe_on_offline_write,
> +       },
>         { }     /* terminate */
>  };
>
> --
> 1.8.3.1
>

