Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id B98176B0389
	for <linux-mm@kvack.org>; Mon, 13 Feb 2017 07:24:46 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id u65so36337813wrc.6
        for <linux-mm@kvack.org>; Mon, 13 Feb 2017 04:24:46 -0800 (PST)
Received: from pandora.armlinux.org.uk (pandora.armlinux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id y12si13617584wrb.279.2017.02.13.04.24.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 13 Feb 2017 04:24:45 -0800 (PST)
Date: Mon, 13 Feb 2017 12:24:07 +0000
From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH] mm: free reserved area's memmap if possiable
Message-ID: <20170213122407.GX27312@n2100.armlinux.org.uk>
References: <1486987349-58711-1-git-send-email-zhouxianrong@huawei.com>
 <20170213121659.GM1512@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170213121659.GM1512@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: zhouxianrong@huawei.com, mark.rutland@arm.com, wangkefeng.wang@huawei.com, srikar@linux.vnet.ibm.com, Mi.Sophia.Wang@huawei.com, catalin.marinas@arm.com, linux-mm@kvack.org, zhangshiming5@huawei.com, frowand.list@gmail.com, zijun_hu@htc.com, jszhang@marvell.com, won.ho.park@huawei.com, kuleshovmail@gmail.com, devicetree@vger.kernel.org, chengang@emindsoft.com.cn, zhouxiyu@huawei.com, tj@kernel.org, robh+dt@kernel.org, weidu.du@huawei.com, linux-arm-kernel@lists.infradead.org, ard.biesheuvel@linaro.org, steve.capper@arm.com, linux-kernel@vger.kernel.org, joe@perches.com, dennis.chen@arm.com, akpm@linux-foundation.org, gkulkarni@caviumnetworks.com

On Mon, Feb 13, 2017 at 12:17:00PM +0000, Will Deacon wrote:
> Adding linux-arm-kernel and devicetree (look for "raw-pfn"), since this
> impacts directly on those.
> 
> On Mon, Feb 13, 2017 at 08:02:29PM +0800, zhouxianrong@huawei.com wrote:
> > From: zhouxianrong <zhouxianrong@huawei.com>
> > 
> > just like freeing no-map area's memmap we could free reserved
> > area's memmap as well only when user of reserved area indicate
> > that we can do this in dts or drivers. that is, user of reserved
> > area know how to use the reserved area who could not memblock_free
> > or free_reserved_xxx the reserved area and regard the area as raw
> > pfn usage. the patch supply a way to users who want to utilize the
> > memmap memory corresponding to raw pfn reserved areas as many as
> > possible.
> 
> I don't really understand this. Can you point me at a specific use-case,
> please? Is CMA involved here?

You don't need "dt permission" to free the memmap page array for the
regions between memory areas.  In fact, adding a DT property for that
goes against the "DT describes the hardware not the implementation"
requirement, since the memmap page array is a Linux implementation
detail.

32-bit ARM has been freeing the memmap page array between memory areas
for years since pre-DT days, and continues to do so.  See
free_unused_memmap().

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
