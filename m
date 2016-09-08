Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id A3A0A6B0069
	for <linux-mm@kvack.org>; Thu,  8 Sep 2016 01:46:42 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id v67so91196939pfv.1
        for <linux-mm@kvack.org>; Wed, 07 Sep 2016 22:46:42 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id n127si45303866pfn.241.2016.09.07.22.46.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Sep 2016 22:46:41 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u885hEiT028131
	for <linux-mm@kvack.org>; Thu, 8 Sep 2016 01:46:41 -0400
Received: from e28smtp07.in.ibm.com (e28smtp07.in.ibm.com [125.16.236.7])
	by mx0a-001b2d01.pphosted.com with ESMTP id 25atrhetau-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 08 Sep 2016 01:46:41 -0400
Received: from localhost
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 8 Sep 2016 11:16:37 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 648A6E0045
	for <linux-mm@kvack.org>; Thu,  8 Sep 2016 11:15:44 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay05.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u885kXkK12255288
	for <linux-mm@kvack.org>; Thu, 8 Sep 2016 11:16:33 +0530
Received: from d28av02.in.ibm.com (localhost [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u885kQXJ010970
	for <linux-mm@kvack.org>; Thu, 8 Sep 2016 11:16:32 +0530
Date: Thu, 08 Sep 2016 11:16:25 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH -v3 03/10] mm, memcg: Support to charge/uncharge multiple
 swap entries
References: <1473266769-2155-1-git-send-email-ying.huang@intel.com> <1473266769-2155-4-git-send-email-ying.huang@intel.com>
In-Reply-To: <1473266769-2155-4-git-send-email-ying.huang@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <57D0FB31.7010605@linux.vnet.ibm.com>
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
