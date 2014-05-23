Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id ED8176B0035
	for <linux-mm@kvack.org>; Fri, 23 May 2014 17:45:53 -0400 (EDT)
Received: by mail-wi0-f177.google.com with SMTP id f8so1521221wiw.10
        for <linux-mm@kvack.org>; Fri, 23 May 2014 14:45:53 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id c4si3850525wjb.108.2014.05.23.14.45.51
        for <linux-mm@kvack.org>;
        Fri, 23 May 2014 14:45:52 -0700 (PDT)
Message-ID: <537fc190.c409c20a.2666.fffff7deSMTPIN_ADDED_BROKEN@mx.google.com>
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] Pass on hwpoison maintainership to Naoya Noriguchi
Date: Fri, 23 May 2014 17:45:30 -0400
In-Reply-To: <1400879739-12614-1-git-send-email-andi@firstfloor.org>
References: <1400879739-12614-1-git-send-email-andi@firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: torvalds@linux-foundation.org, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, ak@linux.intel.com

On Fri, May 23, 2014 at 02:15:39PM -0700, Andi Kleen wrote:
> From: Andi Kleen <ak@linux.intel.com>
> 
> Noriguchi-san has done most of the work on hwpoison in the last years
> and he also does most of the reviewing. So I'm passing on the hwpoison
> maintainership to him.

Thank you, I'll do my best.

# Could please do s/Noriguchi/Horiguchi/g :)
# It will make someone's grep fail in the future.

Naoya

> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Signed-off-by: Andi Kleen <ak@linux.intel.com>
> ---
>  MAINTAINERS | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/MAINTAINERS b/MAINTAINERS
> index c596b74..e84d510 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -4017,9 +4017,8 @@ S:	Odd Fixes
>  F:	drivers/media/usb/hdpvr/
>  
>  HWPOISON MEMORY FAILURE HANDLING
> -M:	Andi Kleen <andi@firstfloor.org>
> +M:	Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>  L:	linux-mm@kvack.org
> -T:	git git://git.kernel.org/pub/scm/linux/kernel/git/ak/linux-mce-2.6.git hwpoison
>  S:	Maintained
>  F:	mm/memory-failure.c
>  F:	mm/hwpoison-inject.c
> -- 
> 1.9.0
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
