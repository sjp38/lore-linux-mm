Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4F56C6B0038
	for <linux-mm@kvack.org>; Thu,  8 Sep 2016 01:46:05 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id hi6so80790120pac.0
        for <linux-mm@kvack.org>; Wed, 07 Sep 2016 22:46:05 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id u79si23833783pfd.18.2016.09.07.22.46.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Sep 2016 22:46:04 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u885hBFi040176
	for <linux-mm@kvack.org>; Thu, 8 Sep 2016 01:46:03 -0400
Received: from e28smtp08.in.ibm.com (e28smtp08.in.ibm.com [125.16.236.8])
	by mx0a-001b2d01.pphosted.com with ESMTP id 25au8s5sbc-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 08 Sep 2016 01:46:03 -0400
Received: from localhost
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 8 Sep 2016 11:16:00 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 77FE5394004E
	for <linux-mm@kvack.org>; Thu,  8 Sep 2016 11:15:58 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay05.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u885jv5U4063368
	for <linux-mm@kvack.org>; Thu, 8 Sep 2016 11:15:57 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u885jsn4009499
	for <linux-mm@kvack.org>; Thu, 8 Sep 2016 11:15:56 +0530
Date: Thu, 08 Sep 2016 11:15:52 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH -v3 01/10] mm, swap: Make swap cluster size same of THP
 size on x86_64
References: <1473266769-2155-1-git-send-email-ying.huang@intel.com> <1473266769-2155-2-git-send-email-ying.huang@intel.com>
In-Reply-To: <1473266769-2155-2-git-send-email-ying.huang@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <57D0FB10.5010609@linux.vnet.ibm.com>
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
