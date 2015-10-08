Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 9B4B46B0254
	for <linux-mm@kvack.org>; Thu,  8 Oct 2015 04:56:39 -0400 (EDT)
Received: by pabve7 with SMTP id ve7so8220723pab.2
        for <linux-mm@kvack.org>; Thu, 08 Oct 2015 01:56:39 -0700 (PDT)
Received: from smtprelay.synopsys.com (us01smtprelay-2.synopsys.com. [198.182.60.111])
        by mx.google.com with ESMTPS id sn5si64875509pbc.85.2015.10.08.01.56.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Oct 2015 01:56:38 -0700 (PDT)
Subject: Re: [PATCHv12 25/37] mm, thp: remove infrastructure for handling
 splitting PMDs
References: <1444145044-72349-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1444145044-72349-26-git-send-email-kirill.shutemov@linux.intel.com>
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Message-ID: <56162EC9.8030803@synopsys.com>
Date: Thu, 8 Oct 2015 14:22:25 +0530
MIME-Version: 1.0
In-Reply-To: <1444145044-72349-26-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh
 Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik
 van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph
 Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha
 Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tuesday 06 October 2015 08:53 PM, Kirill A. Shutemov wrote:
> With new refcounting we don't need to mark PMDs splitting. Let's drop code
> to handle this.
> 
....
>  
> diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
> index 29c57b2cb344..010a7e3f6ad1 100644
> --- a/include/asm-generic/pgtable.h
> +++ b/include/asm-generic/pgtable.h
> @@ -184,11 +184,6 @@ static inline void pmdp_set_wrprotect(struct mm_struct *mm,
>  #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
>  #endif
>  
> -#ifndef __HAVE_ARCH_PMDP_SPLITTING_FLUSH
> -extern void pmdp_splitting_flush(struct vm_area_struct *vma,
> -				 unsigned long address, pmd_t *pmdp);
> -#endif


Hi Kirill,

While at it - you would also want to nuke

Documentation/features/vm/pmdp_splitting_flush/

Thx,
-Vineet

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
