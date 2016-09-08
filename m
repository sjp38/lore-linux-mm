Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id EC5EB6B0038
	for <linux-mm@kvack.org>; Thu,  8 Sep 2016 04:30:46 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id k83so98626023pfa.2
        for <linux-mm@kvack.org>; Thu, 08 Sep 2016 01:30:46 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id f74si46006994pff.158.2016.09.08.01.30.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Sep 2016 01:30:46 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u888RuRT112324
	for <linux-mm@kvack.org>; Thu, 8 Sep 2016 04:30:45 -0400
Received: from e23smtp08.au.ibm.com (e23smtp08.au.ibm.com [202.81.31.141])
	by mx0a-001b2d01.pphosted.com with ESMTP id 25axe6nkb7-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 08 Sep 2016 04:30:45 -0400
Received: from localhost
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 8 Sep 2016 18:30:43 +1000
Received: from d23relay08.au.ibm.com (d23relay08.au.ibm.com [9.185.71.33])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 0B0DB3578053
	for <linux-mm@kvack.org>; Thu,  8 Sep 2016 18:30:40 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u888UdZB5374236
	for <linux-mm@kvack.org>; Thu, 8 Sep 2016 18:30:39 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u888Ud4B014069
	for <linux-mm@kvack.org>; Thu, 8 Sep 2016 18:30:39 +1000
Date: Thu, 08 Sep 2016 14:00:35 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH -v3 04/10] mm, THP, swap: Add swap cluster allocate/free
 functions
References: <1473266769-2155-1-git-send-email-ying.huang@intel.com> <1473266769-2155-5-git-send-email-ying.huang@intel.com>
In-Reply-To: <1473266769-2155-5-git-send-email-ying.huang@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <57D121AB.8060707@linux.vnet.ibm.com>
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
on the mainline kernel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
