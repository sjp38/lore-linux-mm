Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id F37636B0003
	for <linux-mm@kvack.org>; Wed, 23 May 2018 09:04:43 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id e15-v6so2428425wmh.6
        for <linux-mm@kvack.org>; Wed, 23 May 2018 06:04:43 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id f16-v6si4869494edf.188.2018.05.23.06.04.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 May 2018 06:04:42 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w4NCwwBm091587
	for <linux-mm@kvack.org>; Wed, 23 May 2018 09:04:40 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2j572e6ck5-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 23 May 2018 09:04:40 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 23 May 2018 14:04:36 +0100
Subject: Re: [PATCH] MAINTAINERS: Change hugetlbfs maintainer and update files
References: <20180518225236.19079-1-mike.kravetz@oracle.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Wed, 23 May 2018 18:34:29 +0530
MIME-Version: 1.0
In-Reply-To: <20180518225236.19079-1-mike.kravetz@oracle.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <b4960569-0fe0-bad7-327c-398bf2abd7af@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nadia Yvette Chambers <nyc@holomorphy.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Jan Kara <jack@suse.cz>

On 05/19/2018 04:22 AM, Mike Kravetz wrote:
> The current hugetlbfs maintainer has not been active for more than
> a few years.  I have been been active in this area for more than
> two years and plan to remain active in the foreseeable future.
> 
> Also, update the hugetlbfs entry to include linux-mm mail list and
> additional hugetlbfs related files.  hugetlb.c and hugetlb.h are
> not 100% hugetlbfs, but a majority of their content is hugetlbfs
> related.
> 
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>

Thanks Mike !
