Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 12CF66B03E0
	for <linux-mm@kvack.org>; Thu,  6 Jul 2017 02:09:34 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id l34so2277834wrc.12
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 23:09:34 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id d20si802152wrc.300.2017.07.05.23.09.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jul 2017 23:09:31 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v66698mq100066
	for <linux-mm@kvack.org>; Thu, 6 Jul 2017 02:09:30 -0400
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com [202.81.31.148])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2bgvqknj26-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 06 Jul 2017 02:09:30 -0400
Received: from localhost
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 6 Jul 2017 16:09:27 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v6668ADU7537026
	for <linux-mm@kvack.org>; Thu, 6 Jul 2017 16:08:10 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v66689iY013778
	for <linux-mm@kvack.org>; Thu, 6 Jul 2017 16:08:09 +1000
Subject: Re: [patch v2 -mm] mm, hugetlb: schedule when potentially allocating
 many hugepages
References: <alpine.DEB.2.10.1706072102560.29060@chino.kir.corp.google.com>
 <52ee0233-c3cd-d33a-a33b-50d49e050d5c@oracle.com>
 <alpine.DEB.2.10.1706091534580.66176@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1706091535300.66176@chino.kir.corp.google.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Thu, 6 Jul 2017 11:38:02 +0530
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1706091535300.66176@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <3ceb6744-025d-86b9-4a71-beca86efa9e6@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 06/10/2017 04:06 AM, David Rientjes wrote:
> A few hugetlb allocators loop while calling the page allocator and can
> potentially prevent rescheduling if the page allocator slowpath is not
> utilized.
> 
> Conditionally schedule when large numbers of hugepages can be allocated.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Fixes a task which was getting hung while writing like 10000
hugepages (16MB on POWER8) into /proc/sys/vm/nr_hugepages.

Tested-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
