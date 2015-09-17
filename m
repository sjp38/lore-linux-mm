Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id E558C6B0038
	for <linux-mm@kvack.org>; Thu, 17 Sep 2015 09:28:28 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so23879563wic.1
        for <linux-mm@kvack.org>; Thu, 17 Sep 2015 06:28:28 -0700 (PDT)
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com. [209.85.212.179])
        by mx.google.com with ESMTPS id di4si4088003wjc.87.2015.09.17.06.28.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Sep 2015 06:28:27 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so27420450wic.1
        for <linux-mm@kvack.org>; Thu, 17 Sep 2015 06:28:27 -0700 (PDT)
Date: Thu, 17 Sep 2015 16:28:25 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC v5 3/3] mm: make swapin readahead to improve thp collapse
 rate
Message-ID: <20150917132825.GA30954@node.dhcp.inet.fi>
References: <1442259105-4420-1-git-send-email-ebru.akagunduz@gmail.com>
 <1442259105-4420-4-git-send-email-ebru.akagunduz@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1442259105-4420-4-git-send-email-ebru.akagunduz@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, riel@redhat.com, iamjoonsoo.kim@lge.com, xiexiuqi@huawei.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hughd@google.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com, raindel@mellanox.com

On Mon, Sep 14, 2015 at 10:31:45PM +0300, Ebru Akagunduz wrote:
> @@ -2655,6 +2696,8 @@ static void collapse_huge_page(struct mm_struct *mm,
>  
>  	anon_vma_lock_write(vma->anon_vma);
>  
> +	__collapse_huge_page_swapin(mm, vma, address, pmd, pte);
> +

Do I miss something, or 'pte' is not initialized at this point?
And the value is not really used in __collapse_huge_page_swapin().

>  	pte = pte_offset_map(pmd, address);
>  	pte_ptl = pte_lockptr(mm, pmd);
