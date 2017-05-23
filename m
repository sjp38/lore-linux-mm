Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9BC466B0279
	for <linux-mm@kvack.org>; Tue, 23 May 2017 14:07:40 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id b74so173137046pfd.2
        for <linux-mm@kvack.org>; Tue, 23 May 2017 11:07:40 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id t184si21070653pgd.216.2017.05.23.11.07.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 May 2017 11:07:39 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4NHx03V135666
	for <linux-mm@kvack.org>; Tue, 23 May 2017 14:07:39 -0400
Received: from e38.co.us.ibm.com (e38.co.us.ibm.com [32.97.110.159])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2amq2ujrpm-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 23 May 2017 14:07:38 -0400
Received: from localhost
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Tue, 23 May 2017 12:07:38 -0600
Date: Tue, 23 May 2017 13:07:30 -0500
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: Re: [HMM 12/15] mm/migrate: new memory migration helper for use with
 device memory v4
References: <20170522165206.6284-1-jglisse@redhat.com>
 <20170522165206.6284-13-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1; format=flowed
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170522165206.6284-13-jglisse@redhat.com>
Message-Id: <20170523180730.5y7zrpakq5oqznut@arbab-laptop.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

On Mon, May 22, 2017 at 12:52:03PM -0400, Jerome Glisse wrote:
>This patch add a new memory migration helpers, which migrate memory
>backing a range of virtual address of a process to different memory
>(which can be allocated through special allocator). It differs from
>numa migration by working on a range of virtual address and thus by
>doing migration in chunk that can be large enough to use DMA engine
>or special copy offloading engine.
>
>Expected users are any one with heterogeneous memory where different
>memory have different characteristics (latency, bandwidth, ...). As
>an example IBM platform with CAPI bus can make use of this feature
>to migrate between regular memory and CAPI device memory. New CPU
>architecture with a pool of high performance memory not manage as
>cache but presented as regular memory (while being faster and with
>lower latency than DDR) will also be prime user of this patch.
>
>Migration to private device memory will be useful for device that
>have large pool of such like GPU, NVidia plans to use HMM for that.

Acked-by: Reza Arbab <arbab@linux.vnet.ibm.com>

-- 
Reza Arbab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
