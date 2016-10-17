Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 150236B0038
	for <linux-mm@kvack.org>; Sun, 16 Oct 2016 22:08:49 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id w11so346121427oia.6
        for <linux-mm@kvack.org>; Sun, 16 Oct 2016 19:08:49 -0700 (PDT)
Received: from szxga03-in.huawei.com ([119.145.14.66])
        by mx.google.com with ESMTPS id p41si10316477otc.1.2016.10.16.19.08.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 16 Oct 2016 19:08:48 -0700 (PDT)
Message-ID: <5804305F.4030302@huawei.com>
Date: Mon, 17 Oct 2016 09:58:55 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] z3fold: fix the potential encode bug in encod_handle
References: <1476331337-17253-1-git-send-email-zhongjiang@huawei.com>
In-Reply-To: <1476331337-17253-1-git-send-email-zhongjiang@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vitalywool@gmail.com, david@fromorbit.com, sjenning@redhat.com, ddstreet@ieee.org, akpm@linux-foundation.org, mhocko@kernel.org, vbabka@suse.cz
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi,  Vitaly

About the following patch,  is it right?

Thanks
zhongjiang
On 2016/10/13 12:02, zhongjiang wrote:
> From: zhong jiang <zhongjiang@huawei.com>
>
> At present, zhdr->first_num plus bud can exceed the BUDDY_MASK
> in encode_handle, it will lead to the the caller handle_to_buddy
> return the error value.
>
> The patch fix the issue by changing the BUDDY_MASK to PAGE_MASK,
> it will be consistent with handle_to_z3fold_header. At the same time,
> change the BUDDY_MASK to PAGE_MASK in handle_to_buddy is better.
>
> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
> ---
>  mm/z3fold.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/mm/z3fold.c b/mm/z3fold.c
> index 8f9e89c..e8fc216 100644
> --- a/mm/z3fold.c
> +++ b/mm/z3fold.c
> @@ -169,7 +169,7 @@ static unsigned long encode_handle(struct z3fold_header *zhdr, enum buddy bud)
>  
>  	handle = (unsigned long)zhdr;
>  	if (bud != HEADLESS)
> -		handle += (bud + zhdr->first_num) & BUDDY_MASK;
> +		handle += (bud + zhdr->first_num) & PAGE_MASK;
>  	return handle;
>  }
>  
> @@ -183,7 +183,7 @@ static struct z3fold_header *handle_to_z3fold_header(unsigned long handle)
>  static enum buddy handle_to_buddy(unsigned long handle)
>  {
>  	struct z3fold_header *zhdr = handle_to_z3fold_header(handle);
> -	return (handle - zhdr->first_num) & BUDDY_MASK;
> +	return (handle - zhdr->first_num) & PAGE_MASK;
>  }
>  
>  /*


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
