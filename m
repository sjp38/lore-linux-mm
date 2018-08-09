Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id E9C756B000A
	for <linux-mm@kvack.org>; Thu,  9 Aug 2018 05:13:43 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id 17-v6so5115594qkz.15
        for <linux-mm@kvack.org>; Thu, 09 Aug 2018 02:13:43 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z28-v6si1994826qtj.337.2018.08.09.02.13.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Aug 2018 02:13:43 -0700 (PDT)
Date: Thu, 9 Aug 2018 05:13:41 -0400 (EDT)
From: Pankaj Gupta <pagupta@redhat.com>
Message-ID: <2036397219.889906.1533806021412.JavaMail.zimbra@redhat.com>
In-Reply-To: <d2345e628a697ee17fdd6e360f7a6790caab10d5.1533811181.git.yi.z.zhang@linux.intel.com>
References: <cover.1533811181.git.yi.z.zhang@linux.intel.com> <d2345e628a697ee17fdd6e360f7a6790caab10d5.1533811181.git.yi.z.zhang@linux.intel.com>
Subject: Re: [PATCH V3 1/4] kvm: remove redundant reserved page check
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yi <yi.z.zhang@linux.intel.com>
Cc: kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, pbonzini@redhat.com, dan j williams <dan.j.williams@intel.com>, jack@suse.cz, hch@lst.de, yu c zhang <yu.c.zhang@intel.com>, linux-mm@kvack.org, rkrcmar@redhat.com, yi z zhang <yi.z.zhang@intel.com>


> 
> PageReserved() is already checked inside kvm_is_reserved_pfn(),
> remove it from kvm_set_pfn_dirty().
> 
> Signed-off-by: Zhang Yi <yi.z.zhang@linux.intel.com>
> Signed-off-by: Zhang Yu <yu.c.zhang@linux.intel.com>
> ---
>  virt/kvm/kvm_main.c | 8 ++------
>  1 file changed, 2 insertions(+), 6 deletions(-)
> 
> diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
> index 8b47507f..c44c406 100644
> --- a/virt/kvm/kvm_main.c
> +++ b/virt/kvm/kvm_main.c
> @@ -1690,12 +1690,8 @@ EXPORT_SYMBOL_GPL(kvm_release_pfn_dirty);
>  
>  void kvm_set_pfn_dirty(kvm_pfn_t pfn)
>  {
> -	if (!kvm_is_reserved_pfn(pfn)) {
> -		struct page *page = pfn_to_page(pfn);
> -
> -		if (!PageReserved(page))
> -			SetPageDirty(page);
> -	}
> +	if (!kvm_is_reserved_pfn(pfn))
> +		SetPageDirty(pfn_to_page(pfn));
>  }
>  EXPORT_SYMBOL_GPL(kvm_set_pfn_dirty);

Acked-by: Pankaj Gupta <pagupta@redhat.com>

>  
> --
> 2.7.4
> 
> 
