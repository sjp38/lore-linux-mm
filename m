Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 85DC22802E6
	for <linux-mm@kvack.org>; Sun, 19 Jul 2015 07:10:40 -0400 (EDT)
Received: by wibud3 with SMTP id ud3so67961294wib.1
        for <linux-mm@kvack.org>; Sun, 19 Jul 2015 04:10:40 -0700 (PDT)
Received: from johanna2.inet.fi (mta-out1.inet.fi. [62.71.2.230])
        by mx.google.com with ESMTP id k8si7366887wia.75.2015.07.19.04.10.38
        for <linux-mm@kvack.org>;
        Sun, 19 Jul 2015 04:10:39 -0700 (PDT)
Date: Sun, 19 Jul 2015 14:10:19 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v4 3/5] pagemap: rework hugetlb and thp report
Message-ID: <20150719111019.GA2392@node.dhcp.inet.fi>
References: <20150714152516.29844.69929.stgit@buzz>
 <20150714153738.29844.39039.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150714153738.29844.39039.stgit@buzz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mark Williamson <mwilliamson@undo-software.com>, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org

On Tue, Jul 14, 2015 at 06:37:39PM +0300, Konstantin Khlebnikov wrote:
> @@ -1073,35 +1047,48 @@ static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
>  	pte_t *pte, *orig_pte;
>  	int err = 0;
>  
> -	if (pmd_trans_huge_lock(pmd, vma, &ptl) == 1) {
> -		u64 flags = 0;
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +	if (pmd_trans_huge_lock(pmdp, vma, &ptl) == 1) {

#ifdef is redundant. pmd_trans_huge_lock() always return 0 for !THP.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
