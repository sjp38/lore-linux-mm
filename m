Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id E73496B04EF
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 01:53:49 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id g9so45915838pfk.13
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 22:53:49 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id n64si11854330pfg.568.2017.07.27.22.53.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jul 2017 22:53:48 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6S5rmiA109698
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 01:53:48 -0400
Received: from e23smtp07.au.ibm.com (e23smtp07.au.ibm.com [202.81.31.140])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2bymq4yc6f-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 01:53:41 -0400
Received: from localhost
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Fri, 28 Jul 2017 15:53:39 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v6S5ragX28639302
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 15:53:36 +1000
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v6S5rSYp032013
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 15:53:28 +1000
Subject: Re: [PATCH V3] mm/madvise: Enable (soft|hard) offline of HugeTLB
 pages at PGD level
References: <20170426035731.6924-1-khandual@linux.vnet.ibm.com>
 <20170516100509.20122-1-khandual@linux.vnet.ibm.com>
 <04ae16b1-8783-fb3b-4715-b96b6644566f@oracle.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Fri, 28 Jul 2017 11:23:34 +0530
MIME-Version: 1.0
In-Reply-To: <04ae16b1-8783-fb3b-4715-b96b6644566f@oracle.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <c495d3d1-fd72-6f27-4397-ffbed7b2b2d3@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org

On 07/28/2017 06:19 AM, Mike Kravetz wrote:
> On 05/16/2017 03:05 AM, Anshuman Khandual wrote:
>> Though migrating gigantic HugeTLB pages does not sound much like real
>> world use case, they can be affected by memory errors. Hence migration
>> at the PGD level HugeTLB pages should be supported just to enable soft
>> and hard offline use cases.
> 
> Hi Anshuman,
> 
> Sorry for the late question, but I just stumbled on this code when
> looking at something else.
> 
> It appears the primary motivation for these changes is to handle
> memory errors in gigantic pages.  In this case, you migrate to

Right.

> another gigantic page.  However, doesn't this assume that there is

Right.

> a pre-allocated gigantic page sitting unused that will be the target
> of the migration?  alloc_huge_page_node will not allocate a gigantic
> page.  Or, am I missing something?

Yes, its in the context of 16GB pages on POWER8 system where all the
gigantic pages are pre allocated from the platform and passed on to
the kernel through the device tree. We dont allocate these gigantic
pages on runtime.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
