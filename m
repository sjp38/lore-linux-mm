Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0D8B16B000A
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 05:13:26 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id w205-v6so488333oiw.21
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 02:13:26 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id t62-v6si14720245oih.223.2018.07.13.02.13.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jul 2018 02:13:24 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w6D94up4025113
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 05:13:24 -0400
Received: from e35.co.us.ibm.com (e35.co.us.ibm.com [32.97.110.153])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2k6p5xyf9g-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 05:13:23 -0400
Received: from localhost
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <abdhalee@linux.vnet.ibm.com>;
	Fri, 13 Jul 2018 03:13:23 -0600
Subject: Re: [next-20180711][Oops] linux-next kernel boot is broken on
 powerpc
From: Abdul Haleem <abdhalee@linux.vnet.ibm.com>
Date: Fri, 13 Jul 2018 14:43:11 +0530
In-Reply-To: <CAGM2rebtisZda0kqhg0u92fTDxC+=zMNNgKFBLH38osphk0fdA@mail.gmail.com>
References: <1531416305.6480.24.camel@abdul.in.ibm.com>
	 <CAGM2rebtisZda0kqhg0u92fTDxC+=zMNNgKFBLH38osphk0fdA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Message-Id: <1531473191.6480.26.camel@abdul.in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: sachinp@linux.vnet.ibm.com, Stephen Rothwell <sfr@canb.auug.org.au>, Michal Hocko <mhocko@suse.com>, sim@linux.vnet.ibm.com, venkatb3@in.ibm.com, LKML <linux-kernel@vger.kernel.org>, manvanth@linux.vnet.ibm.com, Linux Memory Management List <linux-mm@kvack.org>, linux-next@vger.kernel.org, aneesh.kumar@linux.vnet.ibm.com, linuxppc-dev@lists.ozlabs.org

On Thu, 2018-07-12 at 13:44 -0400, Pavel Tatashin wrote:
> > Related commit could be one of below ? I see lots of patches related to mm and could not bisect
> >
> > 5479976fda7d3ab23ba0a4eb4d60b296eb88b866 mm: page_alloc: restore memblock_next_valid_pfn() on arm/arm64
> > 41619b27b5696e7e5ef76d9c692dd7342c1ad7eb mm-drop-vm_bug_on-from-__get_free_pages-fix
> > 531bbe6bd2721f4b66cdb0f5cf5ac14612fa1419 mm: drop VM_BUG_ON from __get_free_pages
> > 479350dd1a35f8bfb2534697e5ca68ee8a6e8dea mm, page_alloc: actually ignore mempolicies for high priority allocations
> > 088018f6fe571444caaeb16e84c9f24f22dfc8b0 mm: skip invalid pages block at a time in zero_resv_unresv()
> 
> Looks like:
> 0ba29a108979 mm/sparse: Remove CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER
> 
> This patch is going to be reverted from linux-next. Abdul, please
> verify that issue is gone once  you revert this patch.

kernel booted fine when the above patch is reverted.

-- 
Regard's

Abdul Haleem
IBM Linux Technology Centre
