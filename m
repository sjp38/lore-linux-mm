Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id ED0B5900002
	for <linux-mm@kvack.org>; Tue,  8 Jul 2014 02:26:28 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id ft15so6639098pdb.35
        for <linux-mm@kvack.org>; Mon, 07 Jul 2014 23:26:28 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id bu3si42755634pbb.98.2014.07.07.23.26.26
        for <linux-mm@kvack.org>;
        Mon, 07 Jul 2014 23:26:27 -0700 (PDT)
Message-ID: <53BB8EEF.6050101@cn.fujitsu.com>
Date: Tue, 8 Jul 2014 14:25:51 +0800
From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v11 2/7] x86: add pmd_[dirty|mkclean] for THP
References: <1404799424-1120-1-git-send-email-minchan@kernel.org> <1404799424-1120-3-git-send-email-minchan@kernel.org>
In-Reply-To: <1404799424-1120-3-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, Linux API <linux-api@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Jason Evans <je@fb.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org

On 07/08/2014 02:03 PM, Minchan Kim wrote:
> MADV_FREE needs pmd_dirty and pmd_mkclean for detecting recent
> overwrite of the contents since MADV_FREE syscall is called for
> THP page.
> 
> This patch adds pmd_dirty and pmd_mkclean for THP page MADV_FREE
> support.
> 
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: "H. Peter Anvin" <hpa@zytor.com>
> Cc: x86@kernel.org
> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Acked-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

> ---
>  arch/x86/include/asm/pgtable.h | 10 ++++++++++
>  1 file changed, 10 insertions(+)
> 
> diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
> index 0ec056012618..329865799653 100644
> --- a/arch/x86/include/asm/pgtable.h
> +++ b/arch/x86/include/asm/pgtable.h
> @@ -104,6 +104,11 @@ static inline int pmd_young(pmd_t pmd)
>  	return pmd_flags(pmd) & _PAGE_ACCESSED;
>  }
>  
> +static inline int pmd_dirty(pmd_t pmd)
> +{
> +	return pmd_flags(pmd) & _PAGE_DIRTY;
> +}
> +
>  static inline int pte_write(pte_t pte)
>  {
>  	return pte_flags(pte) & _PAGE_RW;
> @@ -267,6 +272,11 @@ static inline pmd_t pmd_mkold(pmd_t pmd)
>  	return pmd_clear_flags(pmd, _PAGE_ACCESSED);
>  }
>  
> +static inline pmd_t pmd_mkclean(pmd_t pmd)
> +{
> +	return pmd_clear_flags(pmd, _PAGE_DIRTY);
> +}
> +
>  static inline pmd_t pmd_wrprotect(pmd_t pmd)
>  {
>  	return pmd_clear_flags(pmd, _PAGE_RW);
> 


-- 
Thanks.
Zhang Yanfei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
