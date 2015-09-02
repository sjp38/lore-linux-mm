Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id CE2F36B0256
	for <linux-mm@kvack.org>; Wed,  2 Sep 2015 07:45:53 -0400 (EDT)
Received: by pacwi10 with SMTP id wi10so9239395pac.3
        for <linux-mm@kvack.org>; Wed, 02 Sep 2015 04:45:53 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id pr10si34957553pbb.122.2015.09.02.04.45.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Sep 2015 04:45:53 -0700 (PDT)
Date: Wed, 2 Sep 2015 14:45:18 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH 1/2] memcg: flatten task_struct->memcg_oom
Message-ID: <20150902114518.GA1237@esperanza>
References: <20150828220158.GD11089@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150828220158.GD11089@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: hannes@cmpxchg.org, mhocko@kernel.org, akpm@linux-foundation.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

On Fri, Aug 28, 2015 at 06:01:58PM -0400, Tejun Heo wrote:
> task_struct->memcg_oom is a sub-struct containing fields which are
> used for async memcg oom handling.  Most task_struct fields aren't
> packaged this way and it can lead to unnecessary alignment paddings.
> This patch flattens it.
> 
> * task.memcg_oom.memcg          -> task.memcg_in_oom
> * task.memcg_oom.gfp_mask	-> task.memcg_oom_gfp_mask
> * task.memcg_oom.order          -> task.memcg_oom_order
> * task.memcg_oom.may_oom        -> task.memcg_may_oom
> 
> In addition, task.memcg_may_oom is relocated to where other bitfields
> are which reduces the size of task_struct.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>

Reviewed-by: Vladimir Davydov <vdavydov@parallels.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
