Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 42DC06B0003
	for <linux-mm@kvack.org>; Mon, 22 Oct 2018 16:50:07 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id h16-v6so3734560qto.23
        for <linux-mm@kvack.org>; Mon, 22 Oct 2018 13:50:07 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id x50-v6si487373qvc.6.2018.10.22.13.50.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Oct 2018 13:50:06 -0700 (PDT)
Date: Mon, 22 Oct 2018 16:06:17 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [kvm PATCH 1/2] mm: export __vmalloc_node_range()
Message-ID: <20181022200617.GD14374@char.us.oracle.com>
References: <20181020211200.255171-1-marcorr@google.com>
 <20181020211200.255171-2-marcorr@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181020211200.255171-2-marcorr@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marc Orr <marcorr@google.com>, linux-mm@kvack.org, akpm@linux-foundation.org
Cc: kvm@vger.kernel.org, jmattson@google.com, rientjes@google.com

On Sat, Oct 20, 2018 at 02:11:59PM -0700, Marc Orr wrote:
> The __vmalloc_node_range() is in the include/linux/vmalloc.h file, but
> it's not exported so it can't be used. This patch exports the API. The
> motivation to export it is so that we can do aligned vmalloc's of KVM
> vcpus.

Would it make more sense to change it to not have __ in front of it?
Also you forgot to CC the linux-mm folks. Doing that for you.

> 
> Signed-off-by: Marc Orr <marcorr@google.com>
> ---
>  mm/vmalloc.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index a728fc492557..9e7974ab1da4 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -1763,6 +1763,7 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
>  			  "vmalloc: allocation failure: %lu bytes", real_size);
>  	return NULL;
>  }
> +EXPORT_SYMBOL_GPL(__vmalloc_node_range);
>  
>  /**
>   *	__vmalloc_node  -  allocate virtually contiguous memory
> -- 
> 2.19.1.568.g152ad8e336-goog
> 
