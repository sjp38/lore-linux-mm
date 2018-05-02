Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id D55CD6B0005
	for <linux-mm@kvack.org>; Wed,  2 May 2018 07:05:32 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id k186-v6so8452602oib.7
        for <linux-mm@kvack.org>; Wed, 02 May 2018 04:05:32 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id e203-v6si3749587oia.265.2018.05.02.04.05.31
        for <linux-mm@kvack.org>;
        Wed, 02 May 2018 04:05:31 -0700 (PDT)
Date: Wed, 2 May 2018 12:05:20 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH 1/2] arm64/mm: define ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT
Message-ID: <20180502110441.xuvjs7gu5xir6y72@lakrids.cambridge.arm.com>
References: <1525247672-2165-1-git-send-email-opensource.ganesh@gmail.com>
 <15c56137-e7c4-dbfa-ce5d-f5feeea79e98@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <15c56137-e7c4-dbfa-ce5d-f5feeea79e98@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Ganesh Mahendran <opensource.ganesh@gmail.com>, catalin.marinas@arm.com, will.deacon@arm.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, May 02, 2018 at 11:00:55AM +0200, Laurent Dufour wrote:
> On 02/05/2018 09:54, Ganesh Mahendran wrote:
> > Set ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT for arm64. This
> > enables Speculative Page Fault handler.
> > 
> > Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
> > ---
> > This patch is on top of Laurent's v10 spf
> > ---
> >  arch/arm64/Kconfig | 1 +
> >  1 file changed, 1 insertion(+)
> > 
> > diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> > index eb2cf49..cd583a9 100644
> > --- a/arch/arm64/Kconfig
> > +++ b/arch/arm64/Kconfig
> > @@ -144,6 +144,7 @@ config ARM64
> >  	select SPARSE_IRQ
> >  	select SYSCTL_EXCEPTION_TRACE
> >  	select THREAD_INFO_IN_TASK
> > +	select ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT if SMP
> 
> There is no need to depend on SMP here as the upper
> CONFIG_SPECULATIVE_PAGE_FAULT is depending on SMP.

Additionally, since commit:

  4b3dc9679cf77933 ("arm64: force CONFIG_SMP=y and remove redundant #ifdefs")

... arm64 is always SMP.

Thanks,
Mark.
