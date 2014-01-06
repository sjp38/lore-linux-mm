Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f53.google.com (mail-ee0-f53.google.com [74.125.83.53])
	by kanga.kvack.org (Postfix) with ESMTP id 4100A6B0031
	for <linux-mm@kvack.org>; Mon,  6 Jan 2014 06:24:26 -0500 (EST)
Received: by mail-ee0-f53.google.com with SMTP id b57so7878862eek.12
        for <linux-mm@kvack.org>; Mon, 06 Jan 2014 03:24:25 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e2si83395612eeg.9.2014.01.06.03.24.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 06 Jan 2014 03:24:25 -0800 (PST)
Date: Mon, 6 Jan 2014 12:24:22 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: could you clarify mm/mempolicy: fix !vma in new_vma_page()
Message-ID: <20140106112422.GA27602@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bob Liu <bob.liu@oracle.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hi Wanpeng Li,
I have just noticed 11c731e81bb0 (mm/mempolicy: fix !vma in
new_vma_page()) and I am not sure I understand it. Your changelog claims
"
    page_address_in_vma() may still return -EFAULT because of many other
    conditions in it.  As a result the while loop in new_vma_page() may end
    with vma=NULL.
"

And the patch handles hugetlb case only. I was wondering what are those
"other conditions" that failed in the BUG_ON mentioned in the changelog?
Could you be more specific please?

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
