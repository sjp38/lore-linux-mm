From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [RFC 01/22] Generic show_mem() implementation
Date: Thu, 3 Apr 2008 09:55:45 +0200
Message-ID: <20080403075545.GC4125@osiris.boeblingen.de.ibm.com>
References: <12071688283927-git-send-email-hannes@saeurebad.de> <1207168839586-git-send-email-hannes@saeurebad.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761780AbYDCH4D@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1207168839586-git-send-email-hannes@saeurebad.de>
Sender: linux-kernel-owner@vger.kernel.org
To: Johannes Weiner <hannes@saeurebad.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mingo@elte.hu, davem@davemloft.net, hskinnemoen@atmel.com, cooloney@kernel.org, starvik@axis.com, dhowells@redhat.com, ysato@users.sf.net, takata@linux-m32r.org, geert@linux-m68k.org, ralf@linux-mips.org, kyle@parisc-linux.org, paulus@samba.org, schwidefsky@de.ibm.com, lethal@linux-sh.org, jdike@addtoit.com, miles@gnu.org, chris@zankel.net, rmk@arm.linux.org.uk, tony.luck@intel.com
List-Id: linux-mm.kvack.org

> diff --git a/arch/alpha/Kconfig b/arch/alpha/Kconfig
> index 729cdbd..efffa92 100644
> --- a/arch/alpha/Kconfig
> +++ b/arch/alpha/Kconfig
> @@ -598,6 +598,9 @@ config ALPHA_LARGE_VMALLOC
> 
>  	  Say N unless you know you need gobs and gobs of vmalloc space.
> 
> +config HAVE_ARCH_SHOW_MEM
> +	def_bool y
> +
>  config VERBOSE_MCHECK
>  	bool "Verbose Machine Checks"
> 
> diff --git a/arch/arm/mm/Kconfig b/arch/arm/mm/Kconfig
> index 76348f0..acad217 100644
> --- a/arch/arm/mm/Kconfig
> +++ b/arch/arm/mm/Kconfig
> @@ -673,3 +673,6 @@ config OUTER_CACHE
>  config CACHE_L2X0
>  	bool
>  	select OUTER_CACHE
> +
> +config HAVE_ARCH_SHOW_MEM
> +	def_bool y

These are all not necessary. Better add some global Kconfig option that
gets selected by an arch if it wants the generic implementation.

e.g. we currently have this in arch/s390/Kconfig:

config S390
        def_bool y
        select HAVE_OPROFILE
        select HAVE_KPROBES
        select HAVE_KRETPROBES

just add a select HAVE_GENERIC_SHOWMEM or something like that in the arch
specific patches.
