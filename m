Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 7846F8D0040
	for <linux-mm@kvack.org>; Wed,  2 Mar 2011 11:24:20 -0500 (EST)
Received: from chimera.site ([173.50.240.230]) by xenotime.net for <linux-mm@kvack.org>; Wed, 2 Mar 2011 08:24:13 -0800
Date: Wed, 2 Mar 2011 08:24:12 -0800
From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: [RFC PATCH 1/5] x86/Kconfig: Add Page Cache Accounting entry
Message-Id: <20110302082412.87f153ba.rdunlap@xenotime.net>
In-Reply-To: <1299055090-23976-1-git-send-email-namei.unix@gmail.com>
References: <no>
	<1299055090-23976-1-git-send-email-namei.unix@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Liu Yuan <namei.unix@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jaxboe@fusionio.com, akpm@linux-foundation.org, fengguang.wu@intel.com

On Wed,  2 Mar 2011 16:38:06 +0800 Liu Yuan wrote:

> From: Liu Yuan <tailai.ly@taobao.com>
> 
> Signed-off-by: Liu Yuan <tailai.ly@taobao.com>
> ---
>  arch/x86/Kconfig.debug |    9 +++++++++
>  1 files changed, 9 insertions(+), 0 deletions(-)
> 
> diff --git a/arch/x86/Kconfig.debug b/arch/x86/Kconfig.debug
> index 615e188..f29e32d 100644
> --- a/arch/x86/Kconfig.debug
> +++ b/arch/x86/Kconfig.debug
> @@ -304,4 +304,13 @@ config DEBUG_STRICT_USER_COPY_CHECKS
>  
>  	  If unsure, or if you run an older (pre 4.4) gcc, say N.
>  
> +config PAGE_CACHE_ACCT
> +	bool "Page cache accounting"
> +	---help---
> +	  Enabling this options to account for page cache hit/missed number of
> +	  times. This would allow user space applications get better knowledge
> +	  of underlying page cache system by reading virtual file. The statitics
> +	  per partition are collected.
> +
> +	  If unsure, say N.
>  endmenu
> -- 

rewrite:

	  Enable this option to provide for page cache hit/miss counters.
	  This allows userspace applications to obtain better knowledge of the
	  underlying page cache subsystem by reading a virtual file.
	  Statistics are collect per partition.

questions:
	what virtual file?
	what kind of partition?

---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
