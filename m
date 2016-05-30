Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id F3FB36B0253
	for <linux-mm@kvack.org>; Mon, 30 May 2016 02:57:16 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id i127so82931484ita.2
        for <linux-mm@kvack.org>; Sun, 29 May 2016 23:57:16 -0700 (PDT)
Received: from out4440.biz.mail.alibaba.com (out4440.biz.mail.alibaba.com. [47.88.44.40])
        by mx.google.com with ESMTP id t63si4560979itd.56.2016.05.29.23.57.14
        for <linux-mm@kvack.org>;
        Sun, 29 May 2016 23:57:16 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <001401d1ba3f$897a88b0$9c6f9a10$@alibaba-inc.com>
In-Reply-To: <001401d1ba3f$897a88b0$9c6f9a10$@alibaba-inc.com>
Subject: Re: [RFC PATCH 1/4] mm/hugetlb: Simplify hugetlb unmap
Date: Mon, 30 May 2016 14:56:59 +0800
Message-ID: <001501d1ba40$76c350c0$6449f240$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "'Aneesh Kumar K.V'" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

> @@ -3157,19 +3156,22 @@ void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
>  	tlb_start_vma(tlb, vma);
>  	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
>  	address = start;
> -again:
>  	for (; address < end; address += sz) {

With the again label cut off, you can also make a change in the for line.

thanks
Hillf
>  		ptep = huge_pte_offset(mm, address);
>  		if (!ptep)
>  			continue;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
