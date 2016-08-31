Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 43B256B0038
	for <linux-mm@kvack.org>; Wed, 31 Aug 2016 10:26:46 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id vd14so92928291pab.3
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 07:26:46 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id wn3si167954pab.33.2016.08.31.07.26.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Aug 2016 07:26:45 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id i6so2860226pfe.0
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 07:26:45 -0700 (PDT)
Message-ID: <1472653603.3889.0.camel@gmail.com>
Subject: Re: [PATCH] Update my e-mail address
From: Greg <gvrose8192@gmail.com>
Date: Wed, 31 Aug 2016 07:26:43 -0700
In-Reply-To: <1472644886-9933-1-git-send-email-vdavydov.dev@gmail.com>
References: <1472644886-9933-1-git-send-email-vdavydov.dev@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 2016-08-31 at 15:01 +0300, Vladimir Davydov wrote:
> vdavydov@{parallels,virtuozzo}.com will bounce from now on.
> 
> Signed-off-by: Vladimir Davydov <vdavydov.dev@gmail.com>

Shouldn't MAINTAINERS be in the subject line?

- Greg

> ---
>  .mailmap    | 2 ++
>  MAINTAINERS | 2 +-
>  2 files changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/.mailmap b/.mailmap
> index b18912c5121e..de22daefd9da 100644
> --- a/.mailmap
> +++ b/.mailmap
> @@ -159,6 +159,8 @@ Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
>  Viresh Kumar <vireshk@kernel.org> <viresh.kumar@st.com>
>  Viresh Kumar <vireshk@kernel.org> <viresh.linux@gmail.com>
>  Viresh Kumar <vireshk@kernel.org> <viresh.kumar2@arm.com>
> +Vladimir Davydov <vdavydov.dev@gmail.com> <vdavydov@virtuozzo.com>
> +Vladimir Davydov <vdavydov.dev@gmail.com> <vdavydov@parallels.com>
>  Takashi YOSHII <takashi.yoshii.zj@renesas.com>
>  Yusuke Goda <goda.yusuke@renesas.com>
>  Gustavo Padovan <gustavo@las.ic.unicamp.br>
> diff --git a/MAINTAINERS b/MAINTAINERS
> index d8e81b1dde30..46a7d3093a49 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -3265,7 +3265,7 @@ F:	kernel/cpuset.c
>  CONTROL GROUP - MEMORY RESOURCE CONTROLLER (MEMCG)
>  M:	Johannes Weiner <hannes@cmpxchg.org>
>  M:	Michal Hocko <mhocko@kernel.org>
> -M:	Vladimir Davydov <vdavydov@virtuozzo.com>
> +M:	Vladimir Davydov <vdavydov.dev@gmail.com>
>  L:	cgroups@vger.kernel.org
>  L:	linux-mm@kvack.org
>  S:	Maintained


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
