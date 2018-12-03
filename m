Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2DA966B6650
	for <linux-mm@kvack.org>; Sun,  2 Dec 2018 19:48:54 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id d196so11752161qkb.6
        for <linux-mm@kvack.org>; Sun, 02 Dec 2018 16:48:54 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b5si1766315qtg.383.2018.12.02.16.48.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 02 Dec 2018 16:48:53 -0800 (PST)
Date: Sun, 2 Dec 2018 19:48:49 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH -next] mm/hmm: remove set but not used variable 'devmem'
Message-ID: <20181203004848.GA21092@redhat.com>
References: <1543629971-128377-1-git-send-email-yuehaibing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1543629971-128377-1-git-send-email-yuehaibing@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: YueHaibing <yuehaibing@huawei.com>
Cc: akpm@linux-foundation.org, sfr@canb.auug.org.au, dan.j.williams@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org

On Sat, Dec 01, 2018 at 02:06:11AM +0000, YueHaibing wrote:
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

Reviewed-by: J�r�me Glisse <jglisse@redhat.com>

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
