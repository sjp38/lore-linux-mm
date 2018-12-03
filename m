Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id EAF556B68BE
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 06:11:59 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id 67so12550523qkj.18
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 03:11:59 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n83si7267954qkl.183.2018.12.03.03.11.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 03:11:59 -0800 (PST)
Subject: Re: [PATCH -next] mm/hmm: remove set but not used variable 'devmem'
References: <1543629971-128377-1-git-send-email-yuehaibing@huawei.com>
From: David Hildenbrand <david@redhat.com>
Message-ID: <c009d3b3-3ae5-948d-992a-393b64d25275@redhat.com>
Date: Mon, 3 Dec 2018 12:11:55 +0100
MIME-Version: 1.0
In-Reply-To: <1543629971-128377-1-git-send-email-yuehaibing@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: YueHaibing <yuehaibing@huawei.com>, jglisse@redhat.com, akpm@linux-foundation.org, sfr@canb.auug.org.au, dan.j.williams@intel.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org

On 01.12.18 03:06, YueHaibing wrote:
> Fixes gcc '-Wunused-but-set-variable' warning:
> 
> mm/hmm.c: In function 'hmm_devmem_ref_kill':
> mm/hmm.c:995:21: warning:
>  variable 'devmem' set but not used [-Wunused-but-set-variable]
> 
> It not used any more since commit 35d39f953d4e ("mm, hmm: replace
> hmm_devmem_pages_create() with devm_memremap_pages()")
> 
> Signed-off-by: YueHaibing <yuehaibing@huawei.com>
> ---
>  mm/hmm.c | 3 ---
>  1 file changed, 3 deletions(-)
> 
> diff --git a/mm/hmm.c b/mm/hmm.c
> index 50fbaf8..361f370 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -992,9 +992,6 @@ static void hmm_devmem_ref_exit(void *data)
>  
>  static void hmm_devmem_ref_kill(struct percpu_ref *ref)
>  {
> -	struct hmm_devmem *devmem;
> -
> -	devmem = container_of(ref, struct hmm_devmem, ref);
>  	percpu_ref_kill(ref);
>  }
> 
> 
> 

Reviewed-by: David Hildenbrand <david@redhat.com>

-- 

Thanks,

David / dhildenb
