Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6F1266B0389
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 09:43:13 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id t184so93508124pgt.1
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 06:43:13 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id t7si7603072pfi.147.2017.03.02.06.43.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Mar 2017 06:43:12 -0800 (PST)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v22EclF0022780
	for <linux-mm@kvack.org>; Thu, 2 Mar 2017 09:43:11 -0500
Received: from e28smtp07.in.ibm.com (e28smtp07.in.ibm.com [125.16.236.7])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28xen2ktha-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 02 Mar 2017 09:43:11 -0500
Received: from localhost
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 2 Mar 2017 20:13:08 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id B43FC394004E
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 20:13:06 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay03.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v22Eh6mO18088170
	for <linux-mm@kvack.org>; Thu, 2 Mar 2017 20:13:06 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v22Eh5LM024985
	for <linux-mm@kvack.org>; Thu, 2 Mar 2017 20:13:05 +0530
Subject: Re: [RFC 03/11] mm: remove SWAP_DIRTY in ttu
References: <1488436765-32350-1-git-send-email-minchan@kernel.org>
 <1488436765-32350-4-git-send-email-minchan@kernel.org>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Thu, 2 Mar 2017 20:12:59 +0530
MIME-Version: 1.0
In-Reply-To: <1488436765-32350-4-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <339d97b2-aeda-29ff-514c-d883e87c7a14@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: kernel-team@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Shaohua Li <shli@kernel.org>

On 03/02/2017 12:09 PM, Minchan Kim wrote:
> If we found lazyfree page is dirty, ttuo can just SetPageSwapBakced
> in there like PG_mlocked page and just return with SWAP_FAIL which
> is very natural because the page is not swappable right now so that
> vmscan can activate it. There is no point to introduce new return
> value SWAP_DIRTY in ttu at the moment.

Yeah makes sense. In the process, SetPageSwapBacked marking of the page
is moved from the shrink_page_list() to try_to_unmap_one().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
