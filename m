Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 9E7C56B0253
	for <linux-mm@kvack.org>; Mon, 14 Sep 2015 03:43:21 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so127976301wic.1
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 00:43:21 -0700 (PDT)
Received: from mail-wi0-x233.google.com (mail-wi0-x233.google.com. [2a00:1450:400c:c05::233])
        by mx.google.com with ESMTPS id b4si15509143wiw.10.2015.09.14.00.43.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Sep 2015 00:43:20 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so120702315wic.0
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 00:43:20 -0700 (PDT)
Date: Mon, 14 Sep 2015 09:43:17 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH] numa-balancing: fix confusion in
 /proc/sys/kernel/numa_balancing
Message-ID: <20150914074317.GA8966@gmail.com>
References: <55F6684F.4010007@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55F6684F.4010007@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, zhongjiang@huawei.com, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


* Xishi Qiu <qiuxishi@huawei.com> wrote:

> We can only echo 0 or 1 > "/proc/sys/kernel/numa_balancing", usually 1 means
> enable and 0 means disable. But when echo 1, it shows the value is 65536, this
> is confusion.
> 
> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
> ---
>  kernel/sched/core.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/kernel/sched/core.c b/kernel/sched/core.c
> index 3595403..e97a348 100644
> --- a/kernel/sched/core.c
> +++ b/kernel/sched/core.c
> @@ -2135,7 +2135,7 @@ int sysctl_numa_balancing(struct ctl_table *table, int write,
>  {
>  	struct ctl_table t;
>  	int err;
> -	int state = numabalancing_enabled;
> +	int state = !!numabalancing_enabled;
>  
>  	if (write && !capable(CAP_SYS_ADMIN))
>  		return -EPERM;

So in the latest scheduler tree this variable got renamed, please adjust your 
patch:

  git git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip.git sched/core


Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
