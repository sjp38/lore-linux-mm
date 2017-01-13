Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 697846B0069
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 04:19:04 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id c73so113142184pfb.7
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 01:19:04 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id d11si12024879plj.282.2017.01.13.01.19.03
        for <linux-mm@kvack.org>;
        Fri, 13 Jan 2017 01:19:03 -0800 (PST)
Date: Fri, 13 Jan 2017 09:19:04 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v3] arm64: mm: Fix NOMAP page initialization
Message-ID: <20170113091903.GA22538@arm.com>
References: <20161216165437.21612-1-rrichter@cavium.com>
 <CAKv+Gu_SmTNguC=tSCwYOL2kx-DogLvSYRZc56eGP=JhdrUOsA@mail.gmail.com>
 <c74d6ec6-16ba-dccc-3b0d-a8bedcb46dc5@linaro.org>
 <cbbf14fd-a1cc-2463-ba67-acd6d61e9db1@linaro.org>
 <CAKv+Gu8-+0LUTN0+8OGWRhd22Ls5cMQqTJcjKQK_0N=Uc-0jog@mail.gmail.com>
 <20170109115320.GI4930@rric.localdomain>
 <20170112160535.GF13843@arm.com>
 <20170112185825.GE5020@rric.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170112185825.GE5020@rric.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robert Richter <robert.richter@cavium.com>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>, Hanjun Guo <hanjun.guo@linaro.org>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, David Daney <david.daney@cavium.com>, Mark Rutland <mark.rutland@arm.com>, James Morse <james.morse@arm.com>, Yisheng Xie <xieyisheng1@huawei.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, Jan 12, 2017 at 07:58:25PM +0100, Robert Richter wrote:
> On 12.01.17 16:05:36, Will Deacon wrote:
> > On Mon, Jan 09, 2017 at 12:53:20PM +0100, Robert Richter wrote:
> 
> > > Kernel compile times (3 runs each):
> > > 
> > > pfn_valid_within():
> > > 
> > > real    6m4.088s
> > > user    372m57.607s
> > > sys     16m55.158s
> > > 
> > > real    6m1.532s
> > > user    372m48.453s
> > > sys     16m50.370s
> > > 
> > > real    6m4.061s
> > > user    373m18.753s
> > > sys     16m57.027s
> > 
> > Did you reboot the machine between each build here, or only when changing
> > kernel? If the latter, do you see variations in kernel build time by simply
> > rebooting the same Image?
> 
> I built it in a loop on the shell, so no reboots between builds. Note
> that I was building the kernel in /dev/shm to not access harddisks. I
> think build times should be comparable then since there is no fs
> caching.

I guess I'm really asking what the standard deviation is if you *do* reboot
between builds, using the same kernel. It's hard to tell whether the numbers
are due to the patches, or just because of noise incurred by the way things
happen to initialise.

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
