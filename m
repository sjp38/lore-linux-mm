Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id C60806B0038
	for <linux-mm@kvack.org>; Thu,  8 Sep 2016 01:49:12 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id hi6so80918633pac.0
        for <linux-mm@kvack.org>; Wed, 07 Sep 2016 22:49:12 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id qp8si45252851pac.89.2016.09.07.22.49.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Sep 2016 22:49:12 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u885lWxI077162
	for <linux-mm@kvack.org>; Thu, 8 Sep 2016 01:49:11 -0400
Received: from e28smtp09.in.ibm.com (e28smtp09.in.ibm.com [125.16.236.9])
	by mx0a-001b2d01.pphosted.com with ESMTP id 25axf7ytwe-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 08 Sep 2016 01:49:11 -0400
Received: from localhost
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 8 Sep 2016 11:19:08 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id AD3403940060
	for <linux-mm@kvack.org>; Thu,  8 Sep 2016 11:19:05 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay01.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u885n5k635258388
	for <linux-mm@kvack.org>; Thu, 8 Sep 2016 11:19:05 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u885n3dW016930
	for <linux-mm@kvack.org>; Thu, 8 Sep 2016 11:19:05 +0530
Date: Thu, 08 Sep 2016 11:19:02 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH -v3 04/10] mm, THP, swap: Add swap cluster allocate/free
 functions
References: <1473266769-2155-1-git-send-email-ying.huang@intel.com> <1473266769-2155-5-git-send-email-ying.huang@intel.com>
In-Reply-To: <1473266769-2155-5-git-send-email-ying.huang@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <57D0FBCE.50706@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>

On 09/07/2016 10:16 PM, Huang, Ying wrote:
> From: Huang Ying <ying.huang@intel.com>
> 
> The swap cluster allocation/free functions are added based on the
> existing swap cluster management mechanism for SSD.  These functions
> don't work for the rotating hard disks because the existing swap cluster
> management mechanism doesn't work for them.  The hard disks support may
> be added if someone really need it.  But that needn't be included in
> this patchset.
> 
> This will be used for the THP (Transparent Huge Page) swap support.
> Where one swap cluster will hold the contents of each THP swapped out.

Which tree this series is based against ? This patch does not apply
on the mainline kernel today.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
