Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 0E56E8D003B
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 17:05:39 -0400 (EDT)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id p3KL5W46024258
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 14:05:33 -0700
Received: from pxi15 (pxi15.prod.google.com [10.243.27.15])
	by wpaz17.hot.corp.google.com with ESMTP id p3KL5ITO010124
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 14:05:18 -0700
Received: by pxi15 with SMTP id 15so826041pxi.33
        for <linux-mm@kvack.org>; Wed, 20 Apr 2011 14:05:18 -0700 (PDT)
Date: Wed, 20 Apr 2011 14:05:16 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v3] mm: make expand_downwards symmetrical to
 expand_upwards
In-Reply-To: <20110420174027.4631.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1104201403060.31768@chino.kir.corp.google.com>
References: <20110420161615.462D.A69D9226@jp.fujitsu.com> <BANLkTimfpY3gq8oY6bPDajBW7JN6Hp+A0A@mail.gmail.com> <20110420174027.4631.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, James Bottomley <James.Bottomley@hansenpartnership.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-parisc@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, x86 maintainers <x86@kernel.org>

On Wed, 20 Apr 2011, KOSAKI Motohiro wrote:

> diff --git a/arch/parisc/Kconfig b/arch/parisc/Kconfig
> index 69ff049..0bf9ae8 100644
> --- a/arch/parisc/Kconfig
> +++ b/arch/parisc/Kconfig
> @@ -229,6 +229,12 @@ config HOTPLUG_CPU
>  	default y if SMP
>  	select HOTPLUG
>  
> +config NUMA
> +	bool "NUMA support"
> +	help
> +	  Say Y to compile the kernel to support NUMA (Non-Uniform Memory
> +	  Access).
> +
>  config ARCH_SELECT_MEMORY_MODEL
>  	def_bool y
>  	depends on 64BIT
> @@ -236,6 +242,7 @@ config ARCH_SELECT_MEMORY_MODEL
>  config ARCH_DISCONTIGMEM_ENABLE
>  	def_bool y
>  	depends on 64BIT
> +	depends on NUMA
>  
>  config ARCH_FLATMEM_ENABLE
>  	def_bool y

I think this should probably be

diff --git a/arch/parisc/Kconfig b/arch/parisc/Kconfig
--- a/arch/parisc/Kconfig
+++ b/arch/parisc/Kconfig
@@ -244,6 +244,9 @@ config ARCH_DISCONTIGMEM_DEFAULT
 	def_bool y
 	depends on ARCH_DISCONTIGMEM_ENABLE
 
+config NUMA
+	def_bool ARCH_DISCONTIGMEM_ENABLE
+
 config NODES_SHIFT
 	int
 	default "3"

instead since we don't need CONFIG_NUMA for anything other than 
CONFIG_PA8X00 and 64-bit enabled.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
