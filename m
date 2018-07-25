Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id A9A036B0003
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 22:12:59 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id u130-v6so3764833pgc.0
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 19:12:59 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id j5-v6si12542756pgt.370.2018.07.24.19.12.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jul 2018 19:12:58 -0700 (PDT)
Date: Tue, 24 Jul 2018 21:12:55 -0500
From: Richard Kuo <rkuo@codeaurora.org>
Subject: Re: [PATCH] hexagon: switch to NO_BOOTMEM
Message-ID: <20180725021255.GF12771@codeaurora.org>
References: <1531726998-10971-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20180723212339.GA12771@codeaurora.org>
 <20180724054704.GA16933@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180724054704.GA16933@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-hexagon@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jul 24, 2018 at 08:47:04AM +0300, Mike Rapoport wrote:
> On Mon, Jul 23, 2018 at 04:23:39PM -0500, Richard Kuo wrote:
> > 
> > On Mon, Jul 16, 2018 at 10:43:18AM +0300, Mike Rapoport wrote:
> > > This patch adds registration of the system memory with memblock, eliminates
> > > bootmem initialization and converts early memory reservations from bootmem
> > > to memblock.
> > > 
> > > Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> > 
> > Sorry for the delay, and thanks for this patch.
> > 
> > I think the first memblock_reserve should use ARCH_PFN_OFFSET instead of
> > PHYS_OFFSET.
> 
> memblock_reserve gets physical address rather than a pfn.
> 
> If I read arch/hexagon/include/asm/mem-layout.h correctly, the PHYS_OFFSET
> *is* the physical address of the RAM and ARCH_PFN_OFFSET is the first pfn:
> 
> #define PHYS_PFN_OFFSET	(PHYS_OFFSET >> PAGE_SHIFT)
> #define ARCH_PFN_OFFSET	PHYS_PFN_OFFSET
> 
> Did I miss something?

Sorry, I should have been more clear.  In the size calculation, it's
subtracting the unshifted PHYS_OFFSET from the start page number, which
I'm pretty sure is wrong.


Thanks,
Richard Kuo


-- 
Employee of Qualcomm Innovation Center, Inc.
Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum, 
a Linux Foundation Collaborative Project
