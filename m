Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 393A06B00B3
	for <linux-mm@kvack.org>; Sat,  8 Sep 2012 17:44:02 -0400 (EDT)
Date: Sat, 8 Sep 2012 23:43:59 +0200
From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [PATCH 01/10] Makefile: Add option
	CONFIG_DISABLE_GCC_AUTOMATIC_INLINING
Message-ID: <20120908214359.GA18435@merkur.ravnborg.org>
References: <1347137279-17568-1-git-send-email-elezegarcia@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1347137279-17568-1-git-send-email-elezegarcia@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ezequiel Garcia <elezegarcia@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Marek <mmarek@suse.cz>

On Sat, Sep 08, 2012 at 05:47:50PM -0300, Ezequiel Garcia wrote:
> As its name suggest this option prevents gcc from auto inlining
> small functions. This is very important if one wants to obtain
> traces with accurate call sites.
> 
> Without this option, gcc will collapse some small functions,
> even when not marked as 'inline' thus making impossible to
> correlate the trace caller address to the real function it belongs.
> 
> Of course, the resultant kernel is slower and slightly smaller,
> but that's not an issue if the focus is on tracing accuracy.
> 
> Cc: Michal Marek <mmarek@suse.cz>
> Signed-off-by: Ezequiel Garcia <elezegarcia@gmail.com>
> ---
>  Makefile          |    4 ++++
>  lib/Kconfig.debug |   11 +++++++++++
>  2 files changed, 15 insertions(+), 0 deletions(-)
> 
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

Could we please call this option for:
config CC_DISABLE_AUTOMATIC_INLINING

We have at least a few other options following that naming scheme.
And today we have no options named *GCC_*

	Sam

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
