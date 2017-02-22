Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id F255F6B0387
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 10:31:26 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id j18so2062725ioe.3
        for <linux-mm@kvack.org>; Wed, 22 Feb 2017 07:31:26 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id d15si1839423ioj.51.2017.02.22.07.31.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Feb 2017 07:31:26 -0800 (PST)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1MFTpvB104347
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 10:31:25 -0500
Received: from e19.ny.us.ibm.com (e19.ny.us.ibm.com [129.33.205.209])
	by mx0b-001b2d01.pphosted.com with ESMTP id 28s5ahdt6n-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 10:31:25 -0500
Received: from localhost
	by e19.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Wed, 22 Feb 2017 10:31:24 -0500
Date: Wed, 22 Feb 2017 09:31:18 -0600
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: Re: [HMM v17 06/14] mm/migrate: new memory migration helper for use
 with device memory v3
References: <1485557541-7806-1-git-send-email-jglisse@redhat.com>
 <1485557541-7806-7-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1; format=flowed
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1485557541-7806-7-git-send-email-jglisse@redhat.com>
Message-Id: <20170222153118.xi7rom4mbi4jt37n@arbab-laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

On Fri, Jan 27, 2017 at 05:52:13PM -0500, Jerome Glisse wrote:
>This patch add a new memory migration helpers, which migrate memory
>backing a range of virtual address of a process to different memory
>(which can be allocated through special allocator). It differs from
>numa migration by working on a range of virtual address and thus by
>doing migration in chunk that can be large enough to use DMA engine
>or special copy offloading engine.

Just wanted to say I've found these migration helpers quite useful. I've 
been prototyping some driver code which uses them, rebasing on each HMM 
revision since v14. So for what it's worth, 

Acked-by: Reza Arbab <arbab@linux.vnet.ibm.com>
Tested-by: Reza Arbab <arbab@linux.vnet.ibm.com>

-- 
Reza Arbab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
