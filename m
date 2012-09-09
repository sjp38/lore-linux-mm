Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id A64DD6B005D
	for <linux-mm@kvack.org>; Sun,  9 Sep 2012 17:25:47 -0400 (EDT)
Received: by pbbro12 with SMTP id ro12so1696373pbb.14
        for <linux-mm@kvack.org>; Sun, 09 Sep 2012 14:25:46 -0700 (PDT)
Date: Sun, 9 Sep 2012 14:25:44 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 01/10] Makefile: Add option
 CONFIG_DISABLE_GCC_AUTOMATIC_INLINING
In-Reply-To: <1347137279-17568-1-git-send-email-elezegarcia@gmail.com>
Message-ID: <alpine.DEB.2.00.1209091424580.13346@chino.kir.corp.google.com>
References: <1347137279-17568-1-git-send-email-elezegarcia@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ezequiel Garcia <elezegarcia@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Marek <mmarek@suse.cz>

On Sat, 8 Sep 2012, Ezequiel Garcia wrote:

> diff --git a/Makefile b/Makefile
> index ddf5be9..df6045a 100644
> --- a/Makefile
> +++ b/Makefile
> @@ -561,6 +561,10 @@ else
>  KBUILD_CFLAGS	+= -O2
>  endif
>  
> +ifdef CONFIG_DISABLE_GCC_AUTOMATIC_INLINING
> +KBUILD_CFLAGS	+= -fno-inline-small-functions

This isn't the only option that controls automatic inlining of functions, 
see indirect-inlining, inline-functions, and inline-functions-called-once.

> +endif
> +
>  include $(srctree)/arch/$(SRCARCH)/Makefile
>  
>  ifdef CONFIG_READABLE_ASM
> diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
> index 2403a63..c8fd50f 100644
> --- a/lib/Kconfig.debug
> +++ b/lib/Kconfig.debug
> @@ -1265,6 +1265,17 @@ config LATENCYTOP
>  source mm/Kconfig.debug
>  source kernel/trace/Kconfig
>  
> +config DISABLE_GCC_AUTOMATIC_INLINING
> +	bool "Disable gcc automatic inlining"
> +	depends on TRACING
> +	help
> +	  This option tells gcc he's not allowed to inline functions automatically,
> +	  when they are not marked as 'inline'.
> +	  In turn, this enables to trace an event with an accurate call site.
> +	  Of course, the resultant kernel is slower and slightly smaller.
> +
> +	  Select this option only if you want to trace call sites accurately.
> +
>  config PROVIDE_OHCI1394_DMA_INIT
>  	bool "Remote debugging over FireWire early on boot"
>  	depends on PCI && X86
> -- 
> 1.7.8.6
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
