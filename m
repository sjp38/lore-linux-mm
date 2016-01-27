Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 3065C6B0005
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 04:55:50 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id p63so17745687wmp.1
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 01:55:50 -0800 (PST)
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com. [195.75.94.107])
        by mx.google.com with ESMTPS id z137si11097594wmc.117.2016.01.27.01.55.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 27 Jan 2016 01:55:49 -0800 (PST)
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <heiko.carstens@de.ibm.com>;
	Wed, 27 Jan 2016 09:55:48 -0000
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 2C4E617D8059
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 09:55:55 +0000 (GMT)
Received: from d06av09.portsmouth.uk.ibm.com (d06av09.portsmouth.uk.ibm.com [9.149.37.250])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u0R9tkeX48234580
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 09:55:46 GMT
Received: from d06av09.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av09.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u0R9tjUk024324
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 02:55:46 -0700
Date: Wed, 27 Jan 2016 10:55:43 +0100
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [PATCH v2 3/3] s390: query dynamic DEBUG_PAGEALLOC setting
Message-ID: <20160127095543.GB4439@osiris>
References: <1453884618-33852-1-git-send-email-borntraeger@de.ibm.com>
 <1453884618-33852-4-git-send-email-borntraeger@de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1453884618-33852-4-git-send-email-borntraeger@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, x86@kernel.org, linuxppc-dev@lists.ozlabs.org, davem@davemloft.net, Joonsoo Kim <iamjoonsoo.kim@lge.com>, davej@codemonkey.org.uk

On Wed, Jan 27, 2016 at 09:50:18AM +0100, Christian Borntraeger wrote:
> We can use debug_pagealloc_enabled() to check if we can map
> the identity mapping with 1MB/2GB pages as well as to print
> the current setting in dump_stack.
> 
> Signed-off-by: Christian Borntraeger <borntraeger@de.ibm.com>
> ---
>  arch/s390/kernel/dumpstack.c |  8 ++++----
>  arch/s390/mm/vmem.c          | 10 ++++------
>  2 files changed, 8 insertions(+), 10 deletions(-)
> 
> diff --git a/arch/s390/kernel/dumpstack.c b/arch/s390/kernel/dumpstack.c
> index dc8e204..3f352e9 100644
> --- a/arch/s390/kernel/dumpstack.c
> +++ b/arch/s390/kernel/dumpstack.c
> @@ -11,6 +11,7 @@
>  #include <linux/export.h>
>  #include <linux/kdebug.h>
>  #include <linux/ptrace.h>
> +#include <linux/mm.h>
>  #include <linux/module.h>
>  #include <linux/sched.h>
>  #include <asm/processor.h>
> @@ -184,10 +185,9 @@ void die(struct pt_regs *regs, const char *str)
>  #endif
>  #ifdef CONFIG_SMP
>  	printk("SMP ");
> -#endif
> -#ifdef CONFIG_DEBUG_PAGEALLOC
> -	printk("DEBUG_PAGEALLOC");
> -#endif
> +#endif	
> +if (debug_pagealloc_enabled())
> +		printk("DEBUG_PAGEALLOC");
>  	printk("\n");

Indentation is broken ("if").
Besides that

Reviewed-by: Heiko Carstens <heiko.carstens@de.ibm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
