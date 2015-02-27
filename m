Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 63FF76B0032
	for <linux-mm@kvack.org>; Thu, 26 Feb 2015 23:03:32 -0500 (EST)
Received: by padfb1 with SMTP id fb1so19398353pad.8
        for <linux-mm@kvack.org>; Thu, 26 Feb 2015 20:03:32 -0800 (PST)
Received: from out21.biz.mail.alibaba.com (out114-136.biz.mail.alibaba.com. [205.204.114.136])
        by mx.google.com with ESMTP id a15si3747562pbu.97.2015.02.26.20.03.29
        for <linux-mm@kvack.org>;
        Thu, 26 Feb 2015 20:03:30 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
Subject: Re: [PATCH 3/4] mm, shmem: Add shmem resident memory accounting
Date: Fri, 27 Feb 2015 12:01:53 +0800
Message-ID: <0be701d05242$202c2eb0$60848c10$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, 'Jerome Marchand' <jmarchan@redhat.com>, linux-kernel <linux-kernel@vger.kernel.org>, 'Andrew Morton' <akpm@linux-foundation.org>, linux-doc@vger.kernel.org, 'Hugh Dickins' <hughd@google.com>, 'Michal Hocko' <mhocko@suse.cz>, "'Kirill A. Shutemov'" <kirill.shutemov@linux.intel.com>, 'Cyrill Gorcunov' <gorcunov@openvz.org>, Hillf Danton <hillf.zj@alibaba-inc.com>

> @@ -501,6 +502,7 @@ static void smaps_pte_entry(pte_t *pte, unsigned long addr,
>  					pte_none(*pte) && vma->vm_file) {
>  		struct address_space *mapping =
>  			file_inode(vma->vm_file)->i_mapping;
> +		pgoff_t pgoff = linear_page_index(vma, addr);
> 
>  		/*
>  		 * shmem does not use swap pte's so we have to consult

This hunk should go to patch 2/4
Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
