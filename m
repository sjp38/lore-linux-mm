Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 547CB6B025E
	for <linux-mm@kvack.org>; Thu, 24 Nov 2016 01:50:40 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id jb2so4731249wjb.6
        for <linux-mm@kvack.org>; Wed, 23 Nov 2016 22:50:40 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id n10si6675196wma.60.2016.11.23.22.50.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Nov 2016 22:50:39 -0800 (PST)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAO6mUGn097145
	for <linux-mm@kvack.org>; Thu, 24 Nov 2016 01:50:37 -0500
Received: from e23smtp08.au.ibm.com (e23smtp08.au.ibm.com [202.81.31.141])
	by mx0a-001b2d01.pphosted.com with ESMTP id 26wshuh8nm-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 24 Nov 2016 01:50:37 -0500
Received: from localhost
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 24 Nov 2016 16:50:34 +1000
Received: from d23relay07.au.ibm.com (d23relay07.au.ibm.com [9.190.26.37])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id C7F7F3578053
	for <linux-mm@kvack.org>; Thu, 24 Nov 2016 17:50:32 +1100 (EST)
Received: from d23av06.au.ibm.com (d23av06.au.ibm.com [9.190.235.151])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uAO6oW8G32636976
	for <linux-mm@kvack.org>; Thu, 24 Nov 2016 17:50:32 +1100
Received: from d23av06.au.ibm.com (localhost [127.0.0.1])
	by d23av06.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uAO6oW5Z025187
	for <linux-mm@kvack.org>; Thu, 24 Nov 2016 17:50:32 +1100
Subject: Re: [PATCH 1/5] mm: migrate: Add mode parameter to support additional
 page copy routines.
References: <20161122162530.2370-1-zi.yan@sent.com>
 <20161122162530.2370-2-zi.yan@sent.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Thu, 24 Nov 2016 12:20:28 +0530
MIME-Version: 1.0
In-Reply-To: <20161122162530.2370-2-zi.yan@sent.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <58368DB4.40809@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@sent.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, Zi Yan <zi.yan@cs.rutgers.edu>, Zi Yan <ziy@nvidia.com>

On 11/22/2016 09:55 PM, Zi Yan wrote:
> From: Zi Yan <zi.yan@cs.rutgers.edu>
> 
> From: Zi Yan <ziy@nvidia.com>

There are multiple "from" for this patch, should be fixed to reflect
just one of them.

> 
> migrate_page_copy() and copy_huge_page() are affected.

In this patch you are just expanding the arguments of both of these
functions to include "migration mode" which will then be implemented
later by subsequent patches or should these patches me merged ? I
guess its okay.

Please reword the commit message to include details.

> 
> Signed-off-by: Zi Yan <ziy@nvidia.com>
> Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>

Just a singled Signed-off-by.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
