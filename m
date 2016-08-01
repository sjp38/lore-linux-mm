Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0096E6B025E
	for <linux-mm@kvack.org>; Mon,  1 Aug 2016 15:54:19 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id ca5so262056136pac.0
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 12:54:18 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id d186si36565472pfc.72.2016.08.01.12.54.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Aug 2016 12:54:18 -0700 (PDT)
Date: Mon, 1 Aug 2016 12:54:17 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: add restriction when memory_hotplug config enable
Message-Id: <20160801125417.ece9c623f03d952a60113a3f@linux-foundation.org>
In-Reply-To: <1470063651-29519-1-git-send-email-zhongjiang@huawei.com>
References: <1470063651-29519-1-git-send-email-zhongjiang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhongjiang <zhongjiang@huawei.com>
Cc: linux-mm@kvack.org, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com

On Mon, 1 Aug 2016 23:00:51 +0800 zhongjiang <zhongjiang@huawei.com> wrote:

> From: zhong jiang <zhongjiang@huawei.com>
> 
> At present, It is obvious that memory online and offline will fail
> when KASAN enable,

huh, I didn't know that.  What's the problem and are there plans to fix it?

>  therefore, it is necessary to add the condition
> to limit the memory_hotplug when KASAN enable.
> 
> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
> ---
>  mm/Kconfig | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 3e2daef..f6dd77e 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -187,6 +187,7 @@ config MEMORY_HOTPLUG
>  	bool "Allow for memory hot-add"
>  	depends on SPARSEMEM || X86_64_ACPI_NUMA
>  	depends on ARCH_ENABLE_MEMORY_HOTPLUG
> +	depends on !KASAN
>  
>  config MEMORY_HOTPLUG_SPARSE
>  	def_bool y

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
