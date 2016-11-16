Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id C9C4D6B0069
	for <linux-mm@kvack.org>; Wed, 16 Nov 2016 02:16:03 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id i88so76160275pfk.3
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 23:16:03 -0800 (PST)
Received: from EUR03-AM5-obe.outbound.protection.outlook.com (mail-eopbgr30080.outbound.protection.outlook.com. [40.107.3.80])
        by mx.google.com with ESMTPS id r62si30415293pgr.202.2016.11.15.23.16.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 15 Nov 2016 23:16:02 -0800 (PST)
Date: Wed, 16 Nov 2016 15:15:55 +0800
From: Huang Shijie <shijie.huang@arm.com>
Subject: Re: Hugetlb gigantic page and dynamic allocation
Message-ID: <20161116071553.GA31541@sha-win-210.asiapac.arm.com>
References: <877f83ncfa.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <877f83ncfa.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Luiz Capitulino <lcapitulino@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, nd@arm.com

On Wed, Nov 16, 2016 at 12:23:13PM +0530, Aneesh Kumar K.V wrote:
> 
> Hi,
> 
> I was looking at this w.r.t a recent patch series and wondering whether
> the usage of alloc_contig_page is correct there. We do
> 
> 
> static int __alloc_gigantic_page(unsigned long start_pfn,
> 				unsigned long nr_pages)
> {
> 	unsigned long end_pfn = start_pfn + nr_pages;
> 	return alloc_contig_range(start_pfn, end_pfn, MIGRATE_MOVABLE);
> }
> 
> 
> That implies, if we fail in certain case we will mark the page block
> migrate type MIGRATE_MOVABLE . Do we want to do that in all case ?
> What if the start_pfn was convering a page block of MIGRATE_CMA type ?
> Should we skip pageblock with MIGRATE_CMA type when trying to allocate
> gigantic huge page ?
I have not read the code so deep. I will study it when I have time.

Btw: Do we really need the free_contig_range() run like this?
free page one by one? I guess we can optimize it to free pages at the unit
of the page order.

Thanks
Huang Shijie

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
