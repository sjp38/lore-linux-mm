Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f47.google.com (mail-qa0-f47.google.com [209.85.216.47])
	by kanga.kvack.org (Postfix) with ESMTP id C0A736B0038
	for <linux-mm@kvack.org>; Fri, 29 Aug 2014 14:51:48 -0400 (EDT)
Received: by mail-qa0-f47.google.com with SMTP id x12so2557963qac.34
        for <linux-mm@kvack.org>; Fri, 29 Aug 2014 11:51:48 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u6si1385219qap.12.2014.08.29.11.51.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Aug 2014 11:51:48 -0700 (PDT)
Date: Fri, 29 Aug 2014 14:51:42 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 2/3] Introduce VM_BUG_ON_VMA
Message-ID: <20140829185142.GB12774@nhori.bos.redhat.com>
References: <1409324059-28692-1-git-send-email-sasha.levin@oracle.com>
 <1409324059-28692-2-git-send-email-sasha.levin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1409324059-28692-2-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, khlebnikov@openvz.org, riel@redhat.com, mgorman@suse.de, mhocko@suse.cz, hughd@google.com, vbabka@suse.cz, walken@google.com, minchan@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Aug 29, 2014 at 10:54:18AM -0400, Sasha Levin wrote:
> Very similar to VM_BUG_ON_PAGE but dumps VMA information instead.
> 
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

> ---
>  include/linux/mmdebug.h |    8 ++++++++
>  1 file changed, 8 insertions(+)
> 
> diff --git a/include/linux/mmdebug.h b/include/linux/mmdebug.h
> index dfb9333..569e4c8 100644
> --- a/include/linux/mmdebug.h
> +++ b/include/linux/mmdebug.h
> @@ -20,12 +20,20 @@ void dump_vma(const struct vm_area_struct *vma);
>  			BUG();						\
>  		}							\
>  	} while (0)
> +#define VM_BUG_ON_VMA(cond, vma)					\
> +	do {								\
> +		if (unlikely(cond)) {					\
> +			dump_vma(vma);					\
> +			BUG();						\
> +		}							\
> +	} while (0)
>  #define VM_WARN_ON(cond) WARN_ON(cond)
>  #define VM_WARN_ON_ONCE(cond) WARN_ON_ONCE(cond)
>  #define VM_WARN_ONCE(cond, format...) WARN_ONCE(cond, format)
>  #else
>  #define VM_BUG_ON(cond) BUILD_BUG_ON_INVALID(cond)
>  #define VM_BUG_ON_PAGE(cond, page) VM_BUG_ON(cond)
> +#define VM_BUG_ON_VMA(cond, vma) VM_BUG_ON(cond)
>  #define VM_WARN_ON(cond) BUILD_BUG_ON_INVALID(cond)
>  #define VM_WARN_ON_ONCE(cond) BUILD_BUG_ON_INVALID(cond)
>  #define VM_WARN_ONCE(cond, format...) BUILD_BUG_ON_INVALID(cond)
> -- 
> 1.7.10.4
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
