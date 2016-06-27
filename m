Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id C842E6B0253
	for <linux-mm@kvack.org>; Mon, 27 Jun 2016 09:39:34 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id f89so126845307qtd.1
        for <linux-mm@kvack.org>; Mon, 27 Jun 2016 06:39:34 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t27si3129259qtt.28.2016.06.27.06.39.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Jun 2016 06:39:34 -0700 (PDT)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [PATCH 1/2] mm: CONFIG_ZONE_DEVICE stop depending on CONFIG_EXPERT
References: <146687645727.39261.14620086569655191314.stgit@dwillia2-desk3.amr.corp.intel.com>
	<146687646274.39261.14267596518720371009.stgit@dwillia2-desk3.amr.corp.intel.com>
Date: Mon, 27 Jun 2016 09:39:31 -0400
In-Reply-To: <146687646274.39261.14267596518720371009.stgit@dwillia2-desk3.amr.corp.intel.com>
	(Dan Williams's message of "Sat, 25 Jun 2016 10:41:02 -0700")
Message-ID: <x49a8i692ek.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Eric Sandeen <sandeen@redhat.com>, linux-kernel@vger.kernel.org, linux-nvdimm@ml01.01.org

Dan Williams <dan.j.williams@intel.com> writes:

> When it was first introduced CONFIG_ZONE_DEVICE depended on disabling
> CONFIG_ZONE_DMA, a configuration choice reserved for "experts".
> However, now that the ZONE_DMA conflict has been eliminated it no longer
> makes sense to require CONFIG_EXPERT.
>
> Reported-by: Eric Sandeen <sandeen@redhat.com>
> Reported-by: Jeff Moyer <jmoyer@redhat.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

Acked-by: Jeff Moyer <jmoyer@redhat.com>

> ---
>  mm/Kconfig |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 3e2daef3c946..d109a7a0c1c4 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -673,7 +673,7 @@ config IDLE_PAGE_TRACKING
>  	  See Documentation/vm/idle_page_tracking.txt for more details.
>  
>  config ZONE_DEVICE
> -	bool "Device memory (pmem, etc...) hotplug support" if EXPERT
> +	bool "Device memory (pmem, etc...) hotplug support"
>  	depends on MEMORY_HOTPLUG
>  	depends on MEMORY_HOTREMOVE
>  	depends on SPARSEMEM_VMEMMAP

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
