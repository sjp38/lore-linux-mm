Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 398C06B004D
	for <linux-mm@kvack.org>; Wed, 28 Nov 2012 04:59:50 -0500 (EST)
Date: Wed, 28 Nov 2012 10:59:47 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch] mm: introduce a common interface for balloon pages
 mobility fix
Message-ID: <20121128095947.GE12309@dhcp22.suse.cz>
References: <50a6581a.V3MmP/x4DXU9jUhJ%fengguang.wu@intel.com>
 <alpine.DEB.2.00.1211161147580.2788@chino.kir.corp.google.com>
 <20121116201035.GA18145@t510.redhat.com>
 <alpine.DEB.2.00.1211161402550.17853@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1211271549140.21752@chino.kir.corp.google.com>
 <20121128000355.GA7401@t510.redhat.com>
 <alpine.DEB.2.00.1211271614150.22996@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1211271614150.22996@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Rafael Aquini <aquini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, kbuild test robot <fengguang.wu@intel.com>, linux-mm@kvack.org

On Tue 27-11-12 16:15:59, David Rientjes wrote:
> It's useful to keep memory defragmented so that all high-order page 
> allocations have a chance to succeed, not simply transparent hugepages.  
> Thus, allow balloon compaction for any system with memory compaction 
> enabled, which is the defconfig.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Yes, makes sense.
Acked-by: Michal Hocko <mhocko@suse.cz>

Thanks

> ---
>  mm/Kconfig |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/Kconfig b/mm/Kconfig
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -200,7 +200,7 @@ config SPLIT_PTLOCK_CPUS
>  config BALLOON_COMPACTION
>  	bool "Allow for balloon memory compaction/migration"
>  	def_bool y
> -	depends on TRANSPARENT_HUGEPAGE && VIRTIO_BALLOON
> +	depends on COMPACTION && VIRTIO_BALLOON
>  	help
>  	  Memory fragmentation introduced by ballooning might reduce
>  	  significantly the number of 2MB contiguous memory blocks that can be

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
