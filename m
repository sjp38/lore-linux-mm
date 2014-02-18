Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f54.google.com (mail-qa0-f54.google.com [209.85.216.54])
	by kanga.kvack.org (Postfix) with ESMTP id 947DD6B0036
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 18:49:07 -0500 (EST)
Received: by mail-qa0-f54.google.com with SMTP id i13so24652095qae.27
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 15:49:07 -0800 (PST)
Received: from mail-qc0-f173.google.com (mail-qc0-f173.google.com [209.85.216.173])
        by mx.google.com with ESMTPS id f91si11327258qge.198.2014.02.18.15.49.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 18 Feb 2014 15:49:07 -0800 (PST)
Received: by mail-qc0-f173.google.com with SMTP id i8so26551335qcq.18
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 15:49:06 -0800 (PST)
Date: Tue, 18 Feb 2014 18:49:04 -0500 (EST)
From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: Re: [PATCHv4 2/2] arm: Get rid of meminfo
In-Reply-To: <20140218230710.GO21483@n2100.arm.linux.org.uk>
Message-ID: <alpine.LFD.2.11.1402181848140.17677@knanqh.ubzr>
References: <1392761733-32628-1-git-send-email-lauraa@codeaurora.org> <1392761733-32628-3-git-send-email-lauraa@codeaurora.org> <20140218230710.GO21483@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Laura Abbott <lauraa@codeaurora.org>, David Brown <davidb@codeaurora.org>, Daniel Walker <dwalker@fifo99.com>, Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>, Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>, Eric Miao <eric.y.miao@gmail.com>, Haojian Zhuang <haojian.zhuang@gmail.com>, Ben Dooks <ben-linux@fluff.org>, Kukjin Kim <kgene.kim@samsung.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org, Leif Lindholm <leif.lindholm@linaro.org>, Grygorii Strashko <grygorii.strashko@ti.com>, Catalin Marinas <catalin.marinas@arm.com>, Rob Herring <robherring2@gmail.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Santosh Shilimkar <santosh.shilimkar@ti.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Courtney Cavin <courtney.cavin@sonymobile.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Grant Likely <grant.likely@secretlab.ca>

On Tue, 18 Feb 2014, Russell King - ARM Linux wrote:

> On Tue, Feb 18, 2014 at 02:15:33PM -0800, Laura Abbott wrote:
> > memblock is now fully integrated into the kernel and is the prefered
> > method for tracking memory. Rather than reinvent the wheel with
> > meminfo, migrate to using memblock directly instead of meminfo as
> > an intermediate.
> 
> >  #define NR_BANKS	CONFIG_ARM_NR_BANKS
> >  
> > -struct membank {
> > -	phys_addr_t start;
> > -	phys_addr_t size;
> > -	unsigned int highmem;
> > -};
> > -
> > -struct meminfo {
> > -	int nr_banks;
> > -	struct membank bank[NR_BANKS];
> > -};
> 
> Doesn't this make NR_BANKS (and CONFIG_ARM_NR_BANKS) unused?

Still used in atag_to_fdt.c but I just sent a patch moving it there.


Nicolas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
