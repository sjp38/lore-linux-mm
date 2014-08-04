Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 64A6F6B0035
	for <linux-mm@kvack.org>; Mon,  4 Aug 2014 06:50:24 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id z10so9434539pdj.16
        for <linux-mm@kvack.org>; Mon, 04 Aug 2014 03:50:24 -0700 (PDT)
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com. [202.81.31.148])
        by mx.google.com with ESMTPS id xy5si17217309pbc.57.2014.08.04.03.50.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 04 Aug 2014 03:50:23 -0700 (PDT)
Received: from /spool/local
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 4 Aug 2014 20:50:20 +1000
Received: from d23relay07.au.ibm.com (d23relay07.au.ibm.com [9.190.26.37])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id D6FE22BB0047
	for <linux-mm@kvack.org>; Mon,  4 Aug 2014 20:50:14 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay07.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s74AohOP16515072
	for <linux-mm@kvack.org>; Mon, 4 Aug 2014 20:50:43 +1000
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s74AoCsr029969
	for <linux-mm@kvack.org>; Mon, 4 Aug 2014 20:50:13 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH v13 4/8] powerpc: add pmd_[dirty|mkclean] for THP
In-Reply-To: <1405666386-15095-5-git-send-email-minchan@kernel.org>
References: <1405666386-15095-1-git-send-email-minchan@kernel.org> <1405666386-15095-5-git-send-email-minchan@kernel.org>
Date: Mon, 04 Aug 2014 16:20:07 +0530
Message-ID: <87ppggedgg.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, Linux API <linux-api@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Jason Evans <je@fb.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org

Minchan Kim <minchan@kernel.org> writes:

> MADV_FREE needs pmd_dirty and pmd_mkclean for detecting recent
> overwrite of the contents since MADV_FREE syscall is called for
> THP page.
>
> This patch adds pmd_dirty and pmd_mkclean for THP page MADV_FREE
> support.
>
> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Cc: Paul Mackerras <paulus@samba.org>
> Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> Cc: linuxppc-dev@lists.ozlabs.org

Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  arch/powerpc/include/asm/pgtable-ppc64.h | 2 ++
>  1 file changed, 2 insertions(+)
>
> diff --git a/arch/powerpc/include/asm/pgtable-ppc64.h b/arch/powerpc/include/asm/pgtable-ppc64.h
> index eb9261024f51..c9a4bbe8e179 100644
> --- a/arch/powerpc/include/asm/pgtable-ppc64.h
> +++ b/arch/powerpc/include/asm/pgtable-ppc64.h
> @@ -468,9 +468,11 @@ static inline pte_t *pmdp_ptep(pmd_t *pmd)
>
>  #define pmd_pfn(pmd)		pte_pfn(pmd_pte(pmd))
>  #define pmd_young(pmd)		pte_young(pmd_pte(pmd))
> +#define pmd_dirty(pmd)		pte_dirty(pmd_pte(pmd))
>  #define pmd_mkold(pmd)		pte_pmd(pte_mkold(pmd_pte(pmd)))
>  #define pmd_wrprotect(pmd)	pte_pmd(pte_wrprotect(pmd_pte(pmd)))
>  #define pmd_mkdirty(pmd)	pte_pmd(pte_mkdirty(pmd_pte(pmd)))
> +#define pmd_mkclean(pmd)	pte_pmd(pte_mkclean(pmd_pte(pmd)))
>  #define pmd_mkyoung(pmd)	pte_pmd(pte_mkyoung(pmd_pte(pmd)))
>  #define pmd_mkwrite(pmd)	pte_pmd(pte_mkwrite(pmd_pte(pmd)))
>
> -- 
> 2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
