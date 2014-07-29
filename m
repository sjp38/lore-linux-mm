Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f175.google.com (mail-ie0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id 2C84B6B0036
	for <linux-mm@kvack.org>; Tue, 29 Jul 2014 18:38:19 -0400 (EDT)
Received: by mail-ie0-f175.google.com with SMTP id x19so375512ier.20
        for <linux-mm@kvack.org>; Tue, 29 Jul 2014 15:38:18 -0700 (PDT)
Received: from mail-ig0-x22c.google.com (mail-ig0-x22c.google.com [2607:f8b0:4001:c05::22c])
        by mx.google.com with ESMTPS id t6si27752080ige.21.2014.07.29.15.38.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 29 Jul 2014 15:38:18 -0700 (PDT)
Received: by mail-ig0-f172.google.com with SMTP id h15so6214417igd.17
        for <linux-mm@kvack.org>; Tue, 29 Jul 2014 15:38:18 -0700 (PDT)
Date: Tue, 29 Jul 2014 15:38:16 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/2] mm: mark fault_around_bytes __read_mostly
In-Reply-To: <1406633609-17586-3-git-send-email-kirill.shutemov@linux.intel.com>
Message-ID: <alpine.DEB.2.02.1407291537350.20991@chino.kir.corp.google.com>
References: <1406633609-17586-1-git-send-email-kirill.shutemov@linux.intel.com> <1406633609-17586-3-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andrey Ryabinin <a.ryabinin@samsung.com>, Sasha Levin <sasha.levin@oracle.com>, linux-mm@kvack.org

On Tue, 29 Jul 2014, Kirill A. Shutemov wrote:

> fault_around_bytes can only be changed via debugfs. Let's mark it
> read-mostly.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Suggested-by: David Rientjes <rientjes@google.com>
Acked-by: David Rientjes <rientjes@google.com>

> ---
>  mm/memory.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index 2ce07dc9b52b..ed3073d6a0e0 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2768,7 +2768,8 @@ void do_set_pte(struct vm_area_struct *vma, unsigned long address,
>  	update_mmu_cache(vma, address, pte);
>  }
>  
> -static unsigned long fault_around_bytes = rounddown_pow_of_two(65536);
> +static unsigned long fault_around_bytes __read_mostly =
> +	rounddown_pow_of_two(65536);
>  
>  static inline unsigned long fault_around_pages(void)
>  {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
