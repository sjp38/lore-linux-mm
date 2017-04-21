Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 196EB6B0038
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 00:38:30 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id a103so92960948ioj.8
        for <linux-mm@kvack.org>; Thu, 20 Apr 2017 21:38:30 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id s83si8896049pfi.205.2017.04.20.21.38.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Apr 2017 21:38:29 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3L4Y5Tg060794
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 00:38:28 -0400
Received: from e23smtp02.au.ibm.com (e23smtp02.au.ibm.com [202.81.31.144])
	by mx0a-001b2d01.pphosted.com with ESMTP id 29y9k7u568-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 00:38:25 -0400
Received: from localhost
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Fri, 21 Apr 2017 14:37:49 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v3L4bevF6291938
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 14:37:48 +1000
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v3L4bA9j016284
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 14:37:11 +1000
Subject: Re: [PATCH v5 04/11] mm: thp: introduce
 CONFIG_ARCH_ENABLE_THP_MIGRATION
References: <20170420204752.79703-1-zi.yan@sent.com>
 <20170420204752.79703-5-zi.yan@sent.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Fri, 21 Apr 2017 10:06:56 +0530
MIME-Version: 1.0
In-Reply-To: <20170420204752.79703-5-zi.yan@sent.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <cd1091b7-a88a-160d-2f20-cd4b3be21ce9@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@sent.com>, n-horiguchi@ah.jp.nec.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, mhocko@kernel.org, khandual@linux.vnet.ibm.com, zi.yan@cs.rutgers.edu, dnellans@nvidia.com

On 04/21/2017 02:17 AM, Zi Yan wrote:
> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> 
> Introduces CONFIG_ARCH_ENABLE_THP_MIGRATION to limit thp migration
> functionality to x86_64, which should be safer at the first step.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Aneesh's latest HugeTLB migration enablement on powerpc should
make this work on powerpc platform as well. Will test it out
in some time but for now enabling only on x86 where you have
tested the series makes sense.

Reviewed-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
