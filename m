Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id CCEEE6B0033
	for <linux-mm@kvack.org>; Fri,  3 Feb 2017 13:16:29 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id d123so31632567pfd.0
        for <linux-mm@kvack.org>; Fri, 03 Feb 2017 10:16:29 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id q5si26154422pfk.67.2017.02.03.10.16.28
        for <linux-mm@kvack.org>;
        Fri, 03 Feb 2017 10:16:29 -0800 (PST)
Date: Fri, 3 Feb 2017 18:16:27 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v3] arm64: mm: Fix NOMAP page initialization
Message-ID: <20170203181626.GL23547@arm.com>
References: <cbbf14fd-a1cc-2463-ba67-acd6d61e9db1@linaro.org>
 <CAKv+Gu8-+0LUTN0+8OGWRhd22Ls5cMQqTJcjKQK_0N=Uc-0jog@mail.gmail.com>
 <20170109115320.GI4930@rric.localdomain>
 <20170112160535.GF13843@arm.com>
 <20170112185825.GE5020@rric.localdomain>
 <20170113091903.GA22538@arm.com>
 <20170113131500.GS4930@rric.localdomain>
 <20170117100015.GG5020@rric.localdomain>
 <20170117191656.GS27328@arm.com>
 <20170203151414.GE16822@rric.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170203151414.GE16822@rric.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robert Richter <robert.richter@cavium.com>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>, Hanjun Guo <hanjun.guo@linaro.org>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, David Daney <david.daney@cavium.com>, Mark Rutland <mark.rutland@arm.com>, James Morse <james.morse@arm.com>, Yisheng Xie <xieyisheng1@huawei.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, Feb 03, 2017 at 04:14:14PM +0100, Robert Richter wrote:
> On 17.01.17 19:16:56, Will Deacon wrote:
> > I can't really see the trend given that, for system time, your
> > pfn_valid_within results have a variance of ~9 and the early_pfn_valid
> > results have a variance of ~92. Given that the variance seems to come
> > about due to the reboots, I think we need more numbers to establish whether
> > the data sets end up largely overlapping or if they really are disjoint.
> 
> Assuming the numbers of both versions are not significant, please
> apply one or the other.

I'd rather apply the pfn_valid_within version, but please can you Ack the
patch first, since there was some confusion when it was posted about a
translation fault that was never reproduced.

Thanks,

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
