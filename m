Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 00DA06B0387
	for <linux-mm@kvack.org>; Thu,  9 Feb 2017 09:34:26 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id c80so25758255iod.4
        for <linux-mm@kvack.org>; Thu, 09 Feb 2017 06:34:25 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id l7si18027977ioi.207.2017.02.09.06.34.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Feb 2017 06:34:25 -0800 (PST)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v19EXto8141726
	for <linux-mm@kvack.org>; Thu, 9 Feb 2017 09:34:24 -0500
Received: from e28smtp03.in.ibm.com (e28smtp03.in.ibm.com [125.16.236.3])
	by mx0b-001b2d01.pphosted.com with ESMTP id 28gp3hkju9-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 09 Feb 2017 09:34:24 -0500
Received: from localhost
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 9 Feb 2017 20:04:21 +0530
Received: from d28relay10.in.ibm.com (d28relay10.in.ibm.com [9.184.220.161])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 50916394005E
	for <linux-mm@kvack.org>; Thu,  9 Feb 2017 20:04:19 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay10.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v19EXK4D26280166
	for <linux-mm@kvack.org>; Thu, 9 Feb 2017 20:03:20 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v19EYI7X016277
	for <linux-mm@kvack.org>; Thu, 9 Feb 2017 20:04:18 +0530
Subject: Re: [PATCH] mm/page_alloc: remove redundant init code for
 ZONE_MOVABLE
References: <20170209141731.60208-1-richard.weiyang@gmail.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Thu, 9 Feb 2017 20:04:12 +0530
MIME-Version: 1.0
In-Reply-To: <20170209141731.60208-1-richard.weiyang@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <0dd05827-a3f9-d287-352a-f92fb05400b8@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, mgorman@techsingularity.net, mhocko@suse.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 02/09/2017 07:47 PM, Wei Yang wrote:
> arch_zone_lowest/highest_possible_pfn[] is set to 0 and [ZONE_MOVABLE] is
> skipped in the loop. No need to reset them to 0 again.
> 
> This patch just removes the redundant code.

Yeah, sounds pretty straight forward.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
