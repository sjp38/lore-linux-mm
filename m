Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A08C08D0030
	for <linux-mm@kvack.org>; Mon,  1 Nov 2010 16:20:32 -0400 (EDT)
Date: Mon, 1 Nov 2010 21:09:58 +0100 (CET)
From: Jesper Juhl <jj@chaosbits.net>
Subject: Re: [RFC PATCH] Add Kconfig option for default swappiness
In-Reply-To: <1288548508-22070-1-git-send-email-bgamari.foss@gmail.com>
Message-ID: <alpine.LNX.2.00.1011012108360.12889@swampdragon.chaosbits.net>
References: <1288548508-22070-1-git-send-email-bgamari.foss@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Ben Gamari <bgamari.foss@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, 31 Oct 2010, Ben Gamari wrote:

> This will allow distributions to tune this important vm parameter in a more
> self-contained manner.
> 
> Signed-off-by: Ben Gamari <bgamari.foss@gmail.com>
> ---
>  Documentation/sysctl/vm.txt |    2 +-
>  mm/Kconfig                  |   11 +++++++++++
>  mm/vmscan.c                 |    2 +-
>  3 files changed, 13 insertions(+), 2 deletions(-)
> 
> diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
> index 6c7d18c..792823b 100644
> --- a/Documentation/sysctl/vm.txt
> +++ b/Documentation/sysctl/vm.txt
> @@ -614,7 +614,7 @@ This control is used to define how aggressive the kernel will swap
>  memory pages.  Higher values will increase agressiveness, lower values
>  decrease the amount of swap.
>  
> -The default value is 60.
> +The default value is 60 (changed with CONFIG_DEFAULT_SWAPINESS).
>  
>  ==============================================================
>  
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 9c61158..729ecec 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -61,6 +61,17 @@ config SPARSEMEM_MANUAL
>  
>  endchoice
>  
> +config DEFAULT_SWAPPINESS
> +	int "Default swappiness"
> +	default "60"
> +	range 0 100
> +	help
> +	  This control is used to define how aggressive the kernel will swap
> +	  memory pages.  Higher values will increase agressiveness, lower
> +	  values decrease the amount of swap. Valid values range from 0 to 100.
> +
> +	  If unsure, keep default value of 60.
> +

Perhaps this help text should mention the fact that swapiness setting can 
be changed at runtime (regardless of the set default) by writing to 
/proc/sys/vm/swappiness ???


-- 
Jesper Juhl <jj@chaosbits.net>             http://www.chaosbits.net/
Plain text mails only, please      http://www.expita.com/nomime.html
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
