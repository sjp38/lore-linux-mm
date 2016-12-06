Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 328D06B0069
	for <linux-mm@kvack.org>; Tue,  6 Dec 2016 05:04:27 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 83so548339903pfx.1
        for <linux-mm@kvack.org>; Tue, 06 Dec 2016 02:04:27 -0800 (PST)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0059.outbound.protection.outlook.com. [104.47.0.59])
        by mx.google.com with ESMTPS id x16si18837385pff.226.2016.12.06.02.04.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 06 Dec 2016 02:04:26 -0800 (PST)
Date: Tue, 6 Dec 2016 18:03:59 +0800
From: Huang Shijie <shijie.huang@arm.com>
Subject: Re: [PATCH v3 0/4]  mm: fix the "counter.sh" failure for libhugetlbfs
Message-ID: <20161206100358.GA4619@sha-win-210.asiapac.arm.com>
References: <1480929431-22348-1-git-send-email-shijie.huang@arm.com>
 <20161205093100.GF30758@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20161205093100.GF30758@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Catalin Marinas <Catalin.Marinas@arm.com>, "n-horiguchi@ah.jp.nec.com" <n-horiguchi@ah.jp.nec.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "aneesh.kumar@linux.vnet.ibm.com" <aneesh.kumar@linux.vnet.ibm.com>, "gerald.schaefer@de.ibm.com" <gerald.schaefer@de.ibm.com>, "mike.kravetz@oracle.com" <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Will
 Deacon <Will.Deacon@arm.com>, Steve Capper <Steve.Capper@arm.com>, Kaly Xin <Kaly.Xin@arm.com>, nd <nd@arm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "vbabka@suze.cz" <vbabka@suze.cz>

On Mon, Dec 05, 2016 at 05:31:01PM +0800, Michal Hocko wrote:
> On Mon 05-12-16 17:17:07, Huang Shijie wrote:
> [...]
> >    The failure is caused by:
> >     1) kernel fails to allocate a gigantic page for the surplus case.
> >        And the gather_surplus_pages() will return NULL in the end.
> > 
> >     2) The condition checks for some functions are wrong:
> >         return_unused_surplus_pages()
> >         nr_overcommit_hugepages_store()
> >         hugetlb_overcommit_handler()
> 
> OK, so how is this any different from gigantic (1G) hugetlb pages on
I think there is no different from gigantic (1G) hugetlb pages on
x86_64. Do anyone ever tested the 1G hugetlb pages in x86_64 with the "counter.sh"
before? 

> x86_64? Do we need the same functionality or is it just 32MB not being
> handled in the same way as 1G?
Yes, we need this functionality for gigantic pages, no matter it is
X86_64 or S390 or arm64, no matter it is 32MB or 1G. :)

But anyway, I will try to find some machine and try the 1G gigantic page
on ARM64.

Thanks
Huang Shijie

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
