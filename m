Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 17E7C6B0010
	for <linux-mm@kvack.org>; Thu, 16 Aug 2018 05:21:22 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id 2-v6so2396121plc.11
        for <linux-mm@kvack.org>; Thu, 16 Aug 2018 02:21:22 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x69-v6si28649408pfe.318.2018.08.16.02.21.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Aug 2018 02:21:20 -0700 (PDT)
Date: Thu, 16 Aug 2018 11:21:16 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: introduce kvvirt_to_page() helper
Message-ID: <20180816092116.GT32645@dhcp22.suse.cz>
References: <1534411057-26276-1-git-send-email-lirongqing@baidu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1534411057-26276-1-git-send-email-lirongqing@baidu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li RongQing <lirongqing@baidu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <mawilcox@microsoft.com>, Souptick Joarder <jrdr.linux@gmail.com>

On Thu 16-08-18 17:17:37, Li RongQing wrote:
> The new helper returns address mapping page, which has several users
> in individual subsystem, like mem_to_page in xfs_buf.c and pgv_to_page
> in af_packet.c, after this, they can be unified

Please add users along with the new helper.

> 
> Signed-off-by: Zhang Yu <zhangyu31@baidu.com>
> Signed-off-by: Li RongQing <lirongqing@baidu.com>
> ---
>  include/linux/mm.h | 8 ++++++++
>  1 file changed, 8 insertions(+)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 68a5121694ef..bb34a3c71df5 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -599,6 +599,14 @@ static inline void *kvcalloc(size_t n, size_t size, gfp_t flags)
>  	return kvmalloc_array(n, size, flags | __GFP_ZERO);
>  }
>  
> +static inline struct page *kvvirt_to_page(const void *addr)
> +{
> +	if (!is_vmalloc_addr(addr))
> +		return virt_to_page(addr);
> +	else
> +		return vmalloc_to_page(addr);
> +}
> +
>  extern void kvfree(const void *addr);
>  
>  static inline atomic_t *compound_mapcount_ptr(struct page *page)
> -- 
> 2.16.2
> 

-- 
Michal Hocko
SUSE Labs
