Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 8AB346B0032
	for <linux-mm@kvack.org>; Wed,  7 Aug 2013 18:48:17 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Wed, 7 Aug 2013 18:48:16 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 64A1B38C803B
	for <linux-mm@kvack.org>; Wed,  7 Aug 2013 18:48:12 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r77MmD9u182992
	for <linux-mm@kvack.org>; Wed, 7 Aug 2013 18:48:13 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r77MmDeq009810
	for <linux-mm@kvack.org>; Wed, 7 Aug 2013 18:48:13 -0400
Message-ID: <5202CEAA.9040204@linux.vnet.ibm.com>
Date: Wed, 07 Aug 2013 15:48:10 -0700
From: Cody P Schafer <cody@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm: make lru_add_drain_all() selective
References: <201308071458.r77EwuJV013106@farm-0012.internal.tilera.com> <201308071551.r77FpWTf022475@farm-0012.internal.tilera.com>
In-Reply-To: <201308071551.r77FpWTf022475@farm-0012.internal.tilera.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Metcalf <cmetcalf@tilera.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Frederic Weisbecker <fweisbec@gmail.com>

On 08/06/2013 01:22 PM, Chris Metcalf wrote:
[...]

>
>   /**
> + * schedule_on_each_cpu - execute a function synchronously on each online CPU
> + * @func: the function to call
> + *
> + * schedule_on_each_cpu() executes @func on each online CPU using the
> + * system workqueue and blocks until all CPUs have completed.
> + * schedule_on_each_cpu() is very slow.
> + *
> + * RETURNS:
> + * 0 on success, -errno on failure.
> + */
> +int schedule_on_each_cpu(work_func_t func)
> +{
> +	get_online_cpus();
> +	schedule_on_cpu_mask(func, cpu_online_mask);

Looks like the return value gets lost here.

> +	put_online_cpus();
> +	return 0;
> +}
> +
> +/**
>    * flush_scheduled_work - ensure that any scheduled work has run to completion.
>    *
>    * Forces execution of the kernel-global workqueue and blocks until its

[...]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
