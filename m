Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id DA71C6B0031
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 18:07:45 -0500 (EST)
Received: by mail-wg0-f49.google.com with SMTP id y10so3747326wgg.28
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 15:07:45 -0800 (PST)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id gx8si13630303wib.71.2014.02.18.15.07.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 18 Feb 2014 15:07:44 -0800 (PST)
Date: Tue, 18 Feb 2014 23:07:11 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCHv4 2/2] arm: Get rid of meminfo
Message-ID: <20140218230710.GO21483@n2100.arm.linux.org.uk>
References: <1392761733-32628-1-git-send-email-lauraa@codeaurora.org> <1392761733-32628-3-git-send-email-lauraa@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1392761733-32628-3-git-send-email-lauraa@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>
Cc: David Brown <davidb@codeaurora.org>, Daniel Walker <dwalker@fifo99.com>, Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>, Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>, Eric Miao <eric.y.miao@gmail.com>, Haojian Zhuang <haojian.zhuang@gmail.com>, Ben Dooks <ben-linux@fluff.org>, Kukjin Kim <kgene.kim@samsung.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org, Leif Lindholm <leif.lindholm@linaro.org>, Grygorii Strashko <grygorii.strashko@ti.com>, Catalin Marinas <catalin.marinas@arm.com>, Rob Herring <robherring2@gmail.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Nicolas Pitre <nicolas.pitre@linaro.org>, Santosh Shilimkar <santosh.shilimkar@ti.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Courtney Cavin <courtney.cavin@sonymobile.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Grant Likely <grant.likely@secretlab.ca>

On Tue, Feb 18, 2014 at 02:15:33PM -0800, Laura Abbott wrote:
> memblock is now fully integrated into the kernel and is the prefered
> method for tracking memory. Rather than reinvent the wheel with
> meminfo, migrate to using memblock directly instead of meminfo as
> an intermediate.

>  #define NR_BANKS	CONFIG_ARM_NR_BANKS
>  
> -struct membank {
> -	phys_addr_t start;
> -	phys_addr_t size;
> -	unsigned int highmem;
> -};
> -
> -struct meminfo {
> -	int nr_banks;
> -	struct membank bank[NR_BANKS];
> -};

Doesn't this make NR_BANKS (and CONFIG_ARM_NR_BANKS) unused?

-- 
FTTC broadband for 0.8mile line: 5.8Mbps down 500kbps up.  Estimation
in database were 13.1 to 19Mbit for a good line, about 7.5+ for a bad.
Estimate before purchase was "up to 13.2Mbit".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
