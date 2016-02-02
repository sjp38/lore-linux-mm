Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 61E336B0253
	for <linux-mm@kvack.org>; Tue,  2 Feb 2016 17:59:14 -0500 (EST)
Received: by mail-pf0-f173.google.com with SMTP id n128so1876136pfn.3
        for <linux-mm@kvack.org>; Tue, 02 Feb 2016 14:59:14 -0800 (PST)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id 3si4512853pfo.227.2016.02.02.14.59.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Feb 2016 14:59:13 -0800 (PST)
Received: by mail-pa0-x22b.google.com with SMTP id uo6so1861051pac.1
        for <linux-mm@kvack.org>; Tue, 02 Feb 2016 14:59:13 -0800 (PST)
Date: Tue, 2 Feb 2016 14:59:12 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/hugetlb: fix gigantic page
 initialization/allocation
In-Reply-To: <1454452420-25007-1-git-send-email-mike.kravetz@oracle.com>
Message-ID: <alpine.DEB.2.10.1602021457500.9118@chino.kir.corp.google.com>
References: <1454452420-25007-1-git-send-email-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Jerome Marchand <jmarchan@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>

On Tue, 2 Feb 2016, Mike Kravetz wrote:

> Attempting to preallocate 1G gigantic huge pages at boot time with
> "hugepagesz=1G hugepages=1" on the kernel command line will prevent
> booting with the following:
> 
> kernel BUG at mm/hugetlb.c:1218!
> 
> When mapcount accounting was reworked, the setting of compound_mapcount_ptr
> in prep_compound_gigantic_page was overlooked.  As a result, the validation
> of mapcount in free_huge_page fails.
> 
> The "BUG_ON" checks in free_huge_page were also changed to "VM_BUG_ON_PAGE"
> to assist with debugging.
> 
> Fixes: af5642a8af ("mm: rework mapcount accounting to enable 4k mapping of THPs")
> Suggested-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>

I'm not sure whether this should have a "From: Naoya Horiguchi" line with 
an accompanying sign-off or not, since Naoya debugged and wrote the actual 
fix to prep_compound_gigantic_page().

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
