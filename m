Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f180.google.com (mail-qc0-f180.google.com [209.85.216.180])
	by kanga.kvack.org (Postfix) with ESMTP id B36286B0032
	for <linux-mm@kvack.org>; Fri, 23 Jan 2015 09:52:54 -0500 (EST)
Received: by mail-qc0-f180.google.com with SMTP id r5so6550666qcx.11
        for <linux-mm@kvack.org>; Fri, 23 Jan 2015 06:52:54 -0800 (PST)
Received: from foss-mx-na.foss.arm.com (foss-mx-na.foss.arm.com. [217.140.108.86])
        by mx.google.com with ESMTP id 15si2095424qgt.127.2015.01.23.06.52.53
        for <linux-mm@kvack.org>;
        Fri, 23 Jan 2015 06:52:54 -0800 (PST)
Date: Fri, 23 Jan 2015 14:52:36 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH] ARM: use default ioremap alignment for SMP or LPAE
Message-ID: <20150123145235.GB21789@e104818-lin.cambridge.arm.com>
References: <1421911075-8814-1-git-send-email-s.dyasly@samsung.com>
 <20150122100441.GA19811@e104818-lin.cambridge.arm.com>
 <3060178.HEZJjJCl1e@wuerfel>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3060178.HEZJjJCl1e@wuerfel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Sergey Dyasly <s.dyasly@samsung.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Russell King <linux@arm.linux.org.uk>, Guan Xuetao <gxt@mprc.pku.edu.cn>, "nicolas.pitre@linaro.org" <nicolas.pitre@linaro.org>, James Bottomley <JBottomley@parallels.com>, Will Deacon <Will.Deacon@arm.com>, Arnd Bergmann <arnd.bergmann@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Safonov <d.safonov@partner.samsung.com>

On Thu, Jan 22, 2015 at 11:03:00AM +0000, Arnd Bergmann wrote:
> Unrelated to this question however is whether we want to keep
> supersection mappings as a performance optimization to save TLBs.
> It seems useful to me, but not critical.

Currently in Linux we allow 16MB mappings only if the phys address is
over 32-bit and !LPAE which makes it unlikely for normal RAM with
pre-LPAE hardware.

IIRC a bigger problem was that supersections are optional in the
architecture but there was no CPUID bit field in ARMv6 (and early ARMv7)
to check for their presence. The ID_MMFR3 contains this information but
for example on early Cortex-A8 that bitfield was reserved and the TRM
states "unpredictable" on read (so probably zero in practice).

On newer ARMv7 (not necessarily with LPAE), we could indeed revisit the
16MB section mapping but it won't go well with single zImage if you want
to support earlier ARMv7 or ARMv6.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
