Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f50.google.com (mail-oa0-f50.google.com [209.85.219.50])
	by kanga.kvack.org (Postfix) with ESMTP id 4BD926B0035
	for <linux-mm@kvack.org>; Tue, 22 Apr 2014 02:47:43 -0400 (EDT)
Received: by mail-oa0-f50.google.com with SMTP id i11so3290134oag.37
        for <linux-mm@kvack.org>; Mon, 21 Apr 2014 23:47:43 -0700 (PDT)
Received: from mail-oa0-x231.google.com (mail-oa0-x231.google.com [2607:f8b0:4003:c02::231])
        by mx.google.com with ESMTPS id we10si30629745obc.111.2014.04.21.23.47.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 21 Apr 2014 23:47:42 -0700 (PDT)
Received: by mail-oa0-f49.google.com with SMTP id o6so5122565oag.8
        for <linux-mm@kvack.org>; Mon, 21 Apr 2014 23:47:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1398144620-9630-1-git-send-email-nasa4836@gmail.com>
References: <1398144620-9630-1-git-send-email-nasa4836@gmail.com>
Date: Tue, 22 Apr 2014 14:47:42 +0800
Message-ID: <CAJd=RBA6ZUZ2UBetmcwGciqY8snme-aY60ZhW9F=8CO6kDzMBA@mail.gmail.com>
Subject: Re: [PATCH] hugetlb_cgroup: explicitly init the early_init field
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianyu Zhan <nasa4836@gmail.com>
Cc: Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, containers@lists.linux-foundation.org, Cgroups <cgroups@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Apr 22, 2014 at 1:30 PM, Jianyu Zhan <nasa4836@gmail.com> wrote:
> For a cgroup subsystem who should init early, then it should carefully
> take care of the implementation of css_alloc, because it will be called
> before mm_init() setup the world.
>
> Luckily we don't, and we better explicitly assign the early_init field
> to 0, for document reason.
>
But other fields still missed, if any. Fair?

> Signed-off-by: Jianyu Zhan <nasa4836@gmail.com>
> ---
>  mm/hugetlb_cgroup.c | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
> index 595d7fd..b5368f8 100644
> --- a/mm/hugetlb_cgroup.c
> +++ b/mm/hugetlb_cgroup.c
> @@ -405,4 +405,5 @@ struct cgroup_subsys hugetlb_cgrp_subsys = {
>         .css_alloc      = hugetlb_cgroup_css_alloc,
>         .css_offline    = hugetlb_cgroup_css_offline,
>         .css_free       = hugetlb_cgroup_css_free,
> +       .early_init     = 0,
>  };
> --
> 2.0.0-rc0
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
