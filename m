Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7568A6B02C3
	for <linux-mm@kvack.org>; Sat,  3 Jun 2017 11:15:14 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id k75so21255267lfg.12
        for <linux-mm@kvack.org>; Sat, 03 Jun 2017 08:15:14 -0700 (PDT)
Received: from mail-lf0-x243.google.com (mail-lf0-x243.google.com. [2a00:1450:4010:c07::243])
        by mx.google.com with ESMTPS id n24si3773967lfi.268.2017.06.03.08.15.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 03 Jun 2017 08:15:13 -0700 (PDT)
Received: by mail-lf0-x243.google.com with SMTP id x81so1216317lfb.3
        for <linux-mm@kvack.org>; Sat, 03 Jun 2017 08:15:12 -0700 (PDT)
Date: Sat, 3 Jun 2017 18:15:10 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH] memcg: refactor mem_cgroup_resize_limit()
Message-ID: <20170603151510.GB15130@esperanza>
References: <20170601230212.30578-1-yuzhao@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170601230212.30578-1-yuzhao@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu Zhao <yuzhao@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jun 01, 2017 at 04:02:12PM -0700, Yu Zhao wrote:
> mem_cgroup_resize_limit() and mem_cgroup_resize_memsw_limit() have
> identical logics. Refactor code so we don't need to keep two pieces
> of code that does same thing.
> 
> Signed-off-by: Yu Zhao <yuzhao@google.com>
> ---
>  mm/memcontrol.c | 71 +++++++++------------------------------------------------
>  1 file changed, 11 insertions(+), 60 deletions(-)

Makes sense to me.

Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
