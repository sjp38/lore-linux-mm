Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id DFC416B0069
	for <linux-mm@kvack.org>; Thu,  8 Sep 2016 04:21:59 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id hi6so87735630pac.0
        for <linux-mm@kvack.org>; Thu, 08 Sep 2016 01:21:59 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id zt6si45917728pab.198.2016.09.08.01.21.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Sep 2016 01:21:57 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u888IeBC005576
	for <linux-mm@kvack.org>; Thu, 8 Sep 2016 04:21:56 -0400
Received: from e28smtp09.in.ibm.com (e28smtp09.in.ibm.com [125.16.236.9])
	by mx0a-001b2d01.pphosted.com with ESMTP id 25axf852xx-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 08 Sep 2016 04:21:56 -0400
Received: from localhost
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 8 Sep 2016 13:51:53 +0530
Received: from d28relay06.in.ibm.com (d28relay06.in.ibm.com [9.184.220.150])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 06FC33940061
	for <linux-mm@kvack.org>; Thu,  8 Sep 2016 13:51:51 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay06.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u888LoDI50266346
	for <linux-mm@kvack.org>; Thu, 8 Sep 2016 13:51:50 +0530
Received: from d28av02.in.ibm.com (localhost [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u888LmEY030162
	for <linux-mm@kvack.org>; Thu, 8 Sep 2016 13:51:50 +0530
Date: Thu, 08 Sep 2016 13:51:47 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH -v3 01/10] mm, swap: Make swap cluster size same of THP
 size on x86_64
References: <1473266769-2155-1-git-send-email-ying.huang@intel.com> <1473266769-2155-2-git-send-email-ying.huang@intel.com>
In-Reply-To: <1473266769-2155-2-git-send-email-ying.huang@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <57D11F9B.8060500@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>

On 09/07/2016 10:16 PM, Huang, Ying wrote:
> From: Huang Ying <ying.huang@intel.com>
> 
> In this patch, the size of the swap cluster is changed to that of the
> THP (Transparent Huge Page) on x86_64 architecture (512).  This is for
> the THP swap support on x86_64.  Where one swap cluster will be used to
> hold the contents of each THP swapped out.  And some information of the
> swapped out THP (such as compound map count) will be recorded in the
> swap_cluster_info data structure.
> 
> For other architectures which want THP swap support, THP_SWAP_CLUSTER
> need to be selected in the Kconfig file for the architecture.
> 
> In effect, this will enlarge swap cluster size by 2 times on x86_64.
> Which may make it harder to find a free cluster when the swap space
> becomes fragmented.  So that, this may reduce the continuous swap space
> allocation and sequential write in theory.  The performance test in 0day
> shows no regressions caused by this.

This patch needs to be split into two separate ones

(1) Add THP_SWAP_CLUSTER config option
(2) Enable CONFIG_THP_SWAP_CLUSTER for X86_64

The first patch should explain the proposal and the second patch
should have 86_64 arch specific details, regressions etc as already
been explained in the commit message.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
