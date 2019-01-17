Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2AE818E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 06:26:22 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id d71so5976361pgc.1
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 03:26:22 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 80si1576551pfz.11.2019.01.17.03.26.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Jan 2019 03:26:20 -0800 (PST)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id x0HBPA8r141728
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 06:26:20 -0500
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2q2rte816c-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 06:26:19 -0500
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Thu, 17 Jan 2019 11:26:17 -0000
Date: Thu, 17 Jan 2019 13:26:11 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: Re: [PATCH] mm/page_alloc: check return value of
 memblock_alloc_node_nopanic()
References: <1547621481-8374-1-git-send-email-rppt@linux.ibm.com>
 <5195030D-7ED9-4074-AB6C-92A3AFF11E00@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5195030D-7ED9-4074-AB6C-92A3AFF11E00@oracle.com>
Message-Id: <20190117112611.GB3710@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: William Kucharski <william.kucharski@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jan 17, 2019 at 03:19:35AM -0700, William Kucharski wrote:
> 
> This seems very reasonable, but if the code is just going to panic if the
> allocation fails, why not call memblock_alloc_node() instead?

I've sent patches [1] that remove panic() from memblock_alloc*() and drop
_nopanic variants. After they will be (hopefully) merged,
memblock_alloc_node() will return NULL on error.
 
> If there is a reason we'd prefer to call memblock_alloc_node_nopanic(),
> I'd like to see pgdat->nodeid printed in the panic message as well.

Sure.

[1] https://lore.kernel.org/lkml/1547646261-32535-1-git-send-email-rppt@linux.ibm.com/

-- 
Sincerely yours,
Mike.
