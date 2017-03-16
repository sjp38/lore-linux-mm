Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id DCAC26B038C
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 12:24:11 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id c23so91693243pfj.0
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 09:24:11 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id q5si5762207pgi.98.2017.03.16.09.24.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 09:24:11 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v2GGIiaN091443
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 12:24:10 -0400
Received: from e18.ny.us.ibm.com (e18.ny.us.ibm.com [129.33.205.208])
	by mx0b-001b2d01.pphosted.com with ESMTP id 297kjnrejp-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 12:24:10 -0400
Received: from localhost
	by e18.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Thu, 16 Mar 2017 12:24:09 -0400
Date: Thu, 16 Mar 2017 11:24:02 -0500
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: Re: [HMM 07/16] mm/migrate: new memory migration helper for use with
 device memory v4
References: <1489680335-6594-1-git-send-email-jglisse@redhat.com>
 <1489680335-6594-8-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1; format=flowed
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1489680335-6594-8-git-send-email-jglisse@redhat.com>
Message-Id: <20170316162402.rpkulrjcjoxzzlw4@arbab-laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

On Thu, Mar 16, 2017 at 12:05:26PM -0400, Jerome Glisse wrote:
>This patch add a new memory migration helpers, which migrate memory 
>backing a range of virtual address of a process to different memory 
>(which can be allocated through special allocator). It differs from 
>numa migration by working on a range of virtual address and thus by 
>doing migration in chunk that can be large enough to use DMA engine or 
>special copy offloading engine.

Reviewed-by: Reza Arbab <arbab@linux.vnet.ibm.com>
Tested-by: Reza Arbab <arbab@linux.vnet.ibm.com>

-- 
Reza Arbab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
