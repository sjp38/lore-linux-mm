Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5AD506B0033
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 12:31:53 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id d9so2731736qtd.8
        for <linux-mm@kvack.org>; Tue, 17 Oct 2017 09:31:53 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k54si9043564qta.90.2017.10.17.09.31.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Oct 2017 09:31:52 -0700 (PDT)
Date: Tue, 17 Oct 2017 12:31:49 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH] mm/hmm: remove redundant variable align_end
Message-ID: <20171017163148.GC2933@redhat.com>
References: <20171017143837.23207-1-colin.king@canonical.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20171017143837.23207-1-colin.king@canonical.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Colin King <colin.king@canonical.com>
Cc: linux-mm@kvack.org, kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Oct 17, 2017 at 03:38:37PM +0100, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> Variable align_end is assigned a value but it is never read, so
> the variable is redundant and can be removed. Cleans up the clang
> warning: Value stored to 'align_end' is never read
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Reviewed-by: Jerome Glisse <jglisse@redhat.com>

> ---
>  mm/hmm.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/mm/hmm.c b/mm/hmm.c
> index a88a847bccba..ea19742a5d60 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -803,11 +803,10 @@ static RADIX_TREE(hmm_devmem_radix, GFP_KERNEL);
>  
>  static void hmm_devmem_radix_release(struct resource *resource)
>  {
> -	resource_size_t key, align_start, align_size, align_end;
> +	resource_size_t key, align_start, align_size;
>  
>  	align_start = resource->start & ~(PA_SECTION_SIZE - 1);
>  	align_size = ALIGN(resource_size(resource), PA_SECTION_SIZE);
> -	align_end = align_start + align_size - 1;
>  
>  	mutex_lock(&hmm_devmem_lock);
>  	for (key = resource->start;
> -- 
> 2.14.1
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
