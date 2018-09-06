Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8E6CE6B76B8
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 00:03:56 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id q11-v6so11431827oih.15
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 21:03:56 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id t88-v6si2819680oij.117.2018.09.05.21.03.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Sep 2018 21:03:55 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w863tng8128115
	for <linux-mm@kvack.org>; Thu, 6 Sep 2018 00:03:54 -0400
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com [32.97.110.150])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2mathwcr85-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 06 Sep 2018 00:03:54 -0400
Received: from localhost
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Wed, 5 Sep 2018 22:03:53 -0600
Subject: Re: [RFC PATCH] mm/hugetlb: make hugetlb_lock irq safe
References: <20180905112341.21355-1-aneesh.kumar@linux.ibm.com>
 <20180905130440.GA3729@bombadil.infradead.org>
 <d76771e6-1664-5d38-a5a0-e98f1120494c@linux.ibm.com>
 <20180905134848.GB3729@bombadil.infradead.org>
 <20180905125846.eb0a9ed907b293c1b4c23c23@linux-foundation.org>
 <78b08258-14c8-0e90-97c7-d647a11acb30@oracle.com>
 <20180905150008.59d477c1f78f966a8f9c3cc8@linux-foundation.org>
 <20180905230737.GA14977@bombadil.infradead.org>
 <c03c8851-ce18-56c6-3f37-47f585d70b19@oracle.com>
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Date: Thu, 6 Sep 2018 09:33:45 +0530
MIME-Version: 1.0
In-Reply-To: <c03c8851-ce18-56c6-3f37-47f585d70b19@oracle.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <bb3054c8-3bf3-ba54-793c-a6939bc0acb4@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>, Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 09/06/2018 05:21 AM, Mike Kravetz wrote:

> 
> BTW, free_huge_page called by put_page for hugetlbfs pages may also take
> a subpool specific lock via spin_lock().  See hugepage_subpool_put_pages.
> So, this would also need to take irq context into account.
> 

I missed that. I can take care of that in next patch update based on 
what we decide w.r.t this patch.

-aneesh
