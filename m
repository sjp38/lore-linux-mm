Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8FB406B025E
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 04:46:37 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id g62so28338191pfb.3
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 01:46:37 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id c138si4575402pfb.9.2016.06.15.01.46.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jun 2016 01:46:36 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u5F8hWhD064216
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 04:46:36 -0400
Received: from e28smtp06.in.ibm.com (e28smtp06.in.ibm.com [125.16.236.6])
	by mx0a-001b2d01.pphosted.com with ESMTP id 23jgpdj9v3-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 04:46:36 -0400
Received: from localhost
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 15 Jun 2016 14:16:32 +0530
Received: from d28relay07.in.ibm.com (d28relay07.in.ibm.com [9.184.220.158])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id BCC9B3940073
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 14:16:30 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay07.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u5F8kUS928246218
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 14:16:30 +0530
Received: from d28av02.in.ibm.com (localhost [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u5F8kQw8025009
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 14:16:29 +0530
Date: Wed, 15 Jun 2016 14:16:20 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/compaction: remove unnecessary order check in try_to_compact_pages()
References: <1465973568-3496-1-git-send-email-opensource.ganesh@gmail.com>
In-Reply-To: <1465973568-3496-1-git-send-email-opensource.ganesh@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <576115DC.5030601@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganesh Mahendran <opensource.ganesh@gmail.com>, akpm@linux-foundation.org, vbabka@suse.cz, iamjoonsoo.kim@lge.com, mhocko@suse.com, mina86@mina86.com, minchan@kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 06/15/2016 12:22 PM, Ganesh Mahendran wrote:
> The caller __alloc_pages_direct_compact() already check (order == 0).
> So no need to check again.

Yeah, the caller (__alloc_pages_direct_compact) checks if the order of
allocation is 0. But we can remove it there and keep it in here as this
is the actual entry point for direct page compaction.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
