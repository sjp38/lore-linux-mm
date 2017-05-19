Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5A6EE2806DC
	for <linux-mm@kvack.org>; Fri, 19 May 2017 09:14:45 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id l39so25437681qtb.9
        for <linux-mm@kvack.org>; Fri, 19 May 2017 06:14:45 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id s83si8729623qke.335.2017.05.19.06.14.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 May 2017 06:14:44 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4JD9CwZ110988
	for <linux-mm@kvack.org>; Fri, 19 May 2017 09:14:44 -0400
Received: from e23smtp09.au.ibm.com (e23smtp09.au.ibm.com [202.81.31.142])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2ahwj3aq9t-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 19 May 2017 09:14:43 -0400
Received: from localhost
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Fri, 19 May 2017 23:14:41 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v4JDEURB6815838
	for <linux-mm@kvack.org>; Fri, 19 May 2017 23:14:38 +1000
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v4JDE4hb012524
	for <linux-mm@kvack.org>; Fri, 19 May 2017 23:14:04 +1000
Subject: Re: [PATCH v5 02/11] mm: mempolicy: add queue_pages_node_check()
References: <20170420204752.79703-1-zi.yan@sent.com>
 <20170420204752.79703-3-zi.yan@sent.com>
 <f7a78cb0-0d91-bdbd-4a38-27f94fcefa8a@linux.vnet.ibm.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Fri, 19 May 2017 18:43:37 +0530
MIME-Version: 1.0
In-Reply-To: <f7a78cb0-0d91-bdbd-4a38-27f94fcefa8a@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <16799a52-8a03-7099-5f95-3016808ae65f@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, Zi Yan <zi.yan@sent.com>, n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@kernel.org, zi.yan@cs.rutgers.edu, dnellans@nvidia.com

On 04/21/2017 09:34 AM, Anshuman Khandual wrote:
> On 04/21/2017 02:17 AM, Zi Yan wrote:
>> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>>
>> Introduce a separate check routine related to MPOL_MF_INVERT flag.
>> This patch just does cleanup, no behavioral change.
> 
> Can you please send it separately first, this should be debated
> and merged quickly and not hang on to the series if we have to
> respin again.
> 
> Reviewed-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>

Mel/Andrew,

This does not have any functional changes and very much independent.
Can this clean up be accepted as is ? In that case we will have to
carry one less patch in the series which can make the review process
simpler.

- Anshuman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
