Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 332486B0003
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 01:47:15 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id 20-v6so3171454ois.21
        for <linux-mm@kvack.org>; Mon, 23 Jul 2018 22:47:15 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id s62-v6si7163092oig.134.2018.07.23.22.47.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jul 2018 22:47:13 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w6O5ismR007325
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 01:47:12 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2kdqxass68-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 01:47:12 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 24 Jul 2018 06:47:10 +0100
Date: Tue, 24 Jul 2018 08:47:04 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH] hexagon: switch to NO_BOOTMEM
References: <1531726998-10971-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20180723212339.GA12771@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180723212339.GA12771@codeaurora.org>
Message-Id: <20180724054704.GA16933@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Kuo <rkuo@codeaurora.org>
Cc: Michal Hocko <mhocko@kernel.org>, linux-hexagon@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jul 23, 2018 at 04:23:39PM -0500, Richard Kuo wrote:
> 
> On Mon, Jul 16, 2018 at 10:43:18AM +0300, Mike Rapoport wrote:
> > This patch adds registration of the system memory with memblock, eliminates
> > bootmem initialization and converts early memory reservations from bootmem
> > to memblock.
> > 
> > Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> 
> Sorry for the delay, and thanks for this patch.
> 
> I think the first memblock_reserve should use ARCH_PFN_OFFSET instead of
> PHYS_OFFSET.

memblock_reserve gets physical address rather than a pfn.

If I read arch/hexagon/include/asm/mem-layout.h correctly, the PHYS_OFFSET
*is* the physical address of the RAM and ARCH_PFN_OFFSET is the first pfn:

#define PHYS_PFN_OFFSET	(PHYS_OFFSET >> PAGE_SHIFT)
#define ARCH_PFN_OFFSET	PHYS_PFN_OFFSET

Did I miss something?
 
> If you can amend that I'd be happy to take it through my tree or it can go
> through any other.
> 
> 
> Thanks,
> Richard Kuo
> 
> 
> -- 
> Employee of Qualcomm Innovation Center, Inc.
> Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum, 
> a Linux Foundation Collaborative Project
> 

-- 
Sincerely yours,
Mike.
