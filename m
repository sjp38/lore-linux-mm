Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f174.google.com (mail-io0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 334616B0254
	for <linux-mm@kvack.org>; Mon, 31 Aug 2015 18:58:24 -0400 (EDT)
Received: by iod35 with SMTP id 35so45952491iod.3
        for <linux-mm@kvack.org>; Mon, 31 Aug 2015 15:58:24 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id l2si650623igu.11.2015.08.31.15.58.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Aug 2015 15:58:23 -0700 (PDT)
Date: Mon, 31 Aug 2015 15:58:22 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v1] mm/memblock: Add memblock_first_region_size() helper
Message-Id: <20150831155822.20d35ce3c5101c940c4d0365@linux-foundation.org>
In-Reply-To: <1440703185-16072-1-git-send-email-kuleshovmail@gmail.com>
References: <1440703185-16072-1-git-send-email-kuleshovmail@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Kuleshov <kuleshovmail@gmail.com>
Cc: Tony Luck <tony.luck@intel.com>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Xishi Qiu <qiuxishi@huawei.com>, Baoquan He <bhe@redhat.com>, Robin Holt <holt@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 28 Aug 2015 01:19:45 +0600 Alexander Kuleshov <kuleshovmail@gmail.com> wrote:

> Some architectures (like s390, microblaze and etc...) require size
> of the first memory region. This patch provides new memblock_first_region_size()
> helper for this case.
> 
> ...
>
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -1463,6 +1463,11 @@ phys_addr_t __init_memblock memblock_end_of_DRAM(void)
>  	return (memblock.memory.regions[idx].base + memblock.memory.regions[idx].size);
>  }
>  
> +phys_addr_t __init_memblock memblock_first_region_size(void)
> +{
> +	return memblock.memory.regions[0].size;
> +}
> +
>  void __init memblock_enforce_memory_limit(phys_addr_t limit)
>  {
>  	phys_addr_t max_addr = (phys_addr_t)ULLONG_MAX;

We tend to avoid merging functions which have no callers.  Some actual
callsites should be included in the patch or patch series, please.

This is so we know it's useful, that it's getting runtime tested and to
aid review.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
