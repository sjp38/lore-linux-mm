Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id F41506B0038
	for <linux-mm@kvack.org>; Thu,  8 Sep 2016 04:28:49 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id hi6so88050843pac.0
        for <linux-mm@kvack.org>; Thu, 08 Sep 2016 01:28:49 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id g4si46033408pax.227.2016.09.08.01.28.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Sep 2016 01:28:49 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u888Rqp0146427
	for <linux-mm@kvack.org>; Thu, 8 Sep 2016 04:28:48 -0400
Received: from e23smtp09.au.ibm.com (e23smtp09.au.ibm.com [202.81.31.142])
	by mx0a-001b2d01.pphosted.com with ESMTP id 25au8sbbwy-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 08 Sep 2016 04:28:48 -0400
Received: from localhost
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 8 Sep 2016 18:28:46 +1000
Received: from d23relay06.au.ibm.com (d23relay06.au.ibm.com [9.185.63.219])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 94D132CE8065
	for <linux-mm@kvack.org>; Thu,  8 Sep 2016 18:28:41 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u888Sf0Z66126034
	for <linux-mm@kvack.org>; Thu, 8 Sep 2016 18:28:41 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u888Sem7009155
	for <linux-mm@kvack.org>; Thu, 8 Sep 2016 18:28:41 +1000
Date: Thu, 08 Sep 2016 13:58:36 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH -v3 03/10] mm, memcg: Support to charge/uncharge multiple
 swap entries
References: <1473266769-2155-1-git-send-email-ying.huang@intel.com> <1473266769-2155-4-git-send-email-ying.huang@intel.com>
In-Reply-To: <1473266769-2155-4-git-send-email-ying.huang@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <57D12134.40604@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org

On 09/07/2016 10:16 PM, Huang, Ying wrote:
> From: Huang Ying <ying.huang@intel.com>
> 
> This patch make it possible to charge or uncharge a set of continuous
> swap entries in the swap cgroup.  The number of swap entries is
> specified via an added parameter.
> 
> This will be used for the THP (Transparent Huge Page) swap support.
> Where a swap cluster backing a THP may be allocated and freed as a
> whole.  So a set of continuous swap entries (512 on x86_64) backing one

Please use HPAGE_SIZE / PAGE_SIZE instead of hard coded number like 512.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
