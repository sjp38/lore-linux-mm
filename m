Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vn0-f43.google.com (mail-vn0-f43.google.com [209.85.216.43])
	by kanga.kvack.org (Postfix) with ESMTP id D5E9E6B0032
	for <linux-mm@kvack.org>; Wed, 29 Apr 2015 13:25:06 -0400 (EDT)
Received: by vnbf1 with SMTP id f1so4203701vnb.0
        for <linux-mm@kvack.org>; Wed, 29 Apr 2015 10:25:06 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id qp1si1817509vdb.24.2015.04.29.10.25.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Apr 2015 10:25:06 -0700 (PDT)
Date: Wed, 29 Apr 2015 19:24:58 +0200
From: Mateusz Guzik <mguzik@redhat.com>
Subject: Re: [PATCH 2/2] Fix variable "error" missing initialization
Message-ID: <20150429172457.GD2588@mguzik>
References: <1430323234-17452-1-git-send-email-citypw@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1430323234-17452-1-git-send-email-citypw@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shawn Chang <citypw@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Apr 30, 2015 at 12:00:34AM +0800, Shawn Chang wrote:
> From: Shawn C <citypw@gmail.com>
> 
> Signed-off-by: Shawn C <citypw@gmail.com>
> ---
>  mm/mlock.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/mlock.c b/mm/mlock.c
> index c7f6785..660e5c5 100644
> --- a/mm/mlock.c
> +++ b/mm/mlock.c
> @@ -557,7 +557,7 @@ static int do_mlock(unsigned long start, size_t len, int on)
>  {
>  	unsigned long nstart, end, tmp;
>  	struct vm_area_struct * vma, * prev;
> -	int error;
> +	int error = 0;
>  
>  	VM_BUG_ON(start & ~PAGE_MASK);
>  	VM_BUG_ON(len != PAGE_ALIGN(len));
> -- 
> 1.9.1
> 

This change does not make sense.

The very first read of error is after it gets set.

I see you sent another patch which credited grsecurity. In their
patchset it makes sense - do_mlock is modified in a way which can
interrupt the loop upcoming loop before it gets the chance to set error.

-- 
Mateusz Guzik

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
