Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 28B2D6B0006
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 01:28:21 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id o60-v6so2627187edd.13
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 22:28:21 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id y39-v6si6389623edb.120.2018.07.24.22.28.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jul 2018 22:28:19 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w6P5NZsc112781
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 01:28:17 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2kehqkkayy-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 01:28:17 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 25 Jul 2018 06:28:14 +0100
Date: Wed, 25 Jul 2018 08:28:09 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH] hexagon: switch to NO_BOOTMEM
References: <1531726998-10971-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20180723212339.GA12771@codeaurora.org>
 <20180724054704.GA16933@rapoport-lnx>
 <20180725021255.GF12771@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180725021255.GF12771@codeaurora.org>
Message-Id: <20180725052809.GA25188@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Kuo <rkuo@codeaurora.org>
Cc: Michal Hocko <mhocko@kernel.org>, linux-hexagon@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jul 24, 2018 at 09:12:55PM -0500, Richard Kuo wrote:
> On Tue, Jul 24, 2018 at 08:47:04AM +0300, Mike Rapoport wrote:
> > On Mon, Jul 23, 2018 at 04:23:39PM -0500, Richard Kuo wrote:
> > > 
> > > On Mon, Jul 16, 2018 at 10:43:18AM +0300, Mike Rapoport wrote:
> > > > This patch adds registration of the system memory with memblock, eliminates
> > > > bootmem initialization and converts early memory reservations from bootmem
> > > > to memblock.
> > > > 
> > > > Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> > > 
> > > Sorry for the delay, and thanks for this patch.
> > > 
> > > I think the first memblock_reserve should use ARCH_PFN_OFFSET instead of
> > > PHYS_OFFSET.
> > 
> > memblock_reserve gets physical address rather than a pfn.
> > 
> > If I read arch/hexagon/include/asm/mem-layout.h correctly, the PHYS_OFFSET
> > *is* the physical address of the RAM and ARCH_PFN_OFFSET is the first pfn:
> > 
> > #define PHYS_PFN_OFFSET	(PHYS_OFFSET >> PAGE_SHIFT)
> > #define ARCH_PFN_OFFSET	PHYS_PFN_OFFSET
> > 
> > Did I miss something?
> 
> Sorry, I should have been more clear.  In the size calculation, it's
> subtracting the unshifted PHYS_OFFSET from the start page number, which
> I'm pretty sure is wrong.

Yeah, you're right. I've missed that one.
 
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
