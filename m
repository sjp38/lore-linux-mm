Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id C33B36B0069
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 14:16:58 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id t6so114947288pgt.6
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 11:16:58 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id r82si25821300pfl.199.2017.01.17.11.16.57
        for <linux-mm@kvack.org>;
        Tue, 17 Jan 2017 11:16:57 -0800 (PST)
Date: Tue, 17 Jan 2017 19:16:56 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v3] arm64: mm: Fix NOMAP page initialization
Message-ID: <20170117191656.GS27328@arm.com>
References: <CAKv+Gu_SmTNguC=tSCwYOL2kx-DogLvSYRZc56eGP=JhdrUOsA@mail.gmail.com>
 <c74d6ec6-16ba-dccc-3b0d-a8bedcb46dc5@linaro.org>
 <cbbf14fd-a1cc-2463-ba67-acd6d61e9db1@linaro.org>
 <CAKv+Gu8-+0LUTN0+8OGWRhd22Ls5cMQqTJcjKQK_0N=Uc-0jog@mail.gmail.com>
 <20170109115320.GI4930@rric.localdomain>
 <20170112160535.GF13843@arm.com>
 <20170112185825.GE5020@rric.localdomain>
 <20170113091903.GA22538@arm.com>
 <20170113131500.GS4930@rric.localdomain>
 <20170117100015.GG5020@rric.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170117100015.GG5020@rric.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robert Richter <robert.richter@cavium.com>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>, Hanjun Guo <hanjun.guo@linaro.org>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, David Daney <david.daney@cavium.com>, Mark Rutland <mark.rutland@arm.com>, James Morse <james.morse@arm.com>, Yisheng Xie <xieyisheng1@huawei.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Jan 17, 2017 at 11:00:15AM +0100, Robert Richter wrote:
> On 13.01.17 14:15:00, Robert Richter wrote:
> > On 13.01.17 09:19:04, Will Deacon wrote:
> > > On Thu, Jan 12, 2017 at 07:58:25PM +0100, Robert Richter wrote:
> > > > On 12.01.17 16:05:36, Will Deacon wrote:
> > > > > On Mon, Jan 09, 2017 at 12:53:20PM +0100, Robert Richter wrote:
> > > > 
> > > > > > Kernel compile times (3 runs each):
> > > > > > 
> > > > > > pfn_valid_within():
> > > > > > 
> > > > > > real    6m4.088s
> > > > > > user    372m57.607s
> > > > > > sys     16m55.158s
> > > > > > 
> > > > > > real    6m1.532s
> > > > > > user    372m48.453s
> > > > > > sys     16m50.370s
> > > > > > 
> > > > > > real    6m4.061s
> > > > > > user    373m18.753s
> > > > > > sys     16m57.027s
> > > > > 
> > > > > Did you reboot the machine between each build here, or only when changing
> > > > > kernel? If the latter, do you see variations in kernel build time by simply
> > > > > rebooting the same Image?
> > > > 
> > > > I built it in a loop on the shell, so no reboots between builds. Note
> > > > that I was building the kernel in /dev/shm to not access harddisks. I
> > > > think build times should be comparable then since there is no fs
> > > > caching.
> > > 
> > > I guess I'm really asking what the standard deviation is if you *do* reboot
> > > between builds, using the same kernel. It's hard to tell whether the numbers
> > > are due to the patches, or just because of noise incurred by the way things
> > > happen to initialise.
> > 
> > Ok, I am going to test this.
> 
> See below the data for a test with reboots between every 3 builds (9
> builds per kernel). Though some deviation can be seen between reboots
> there is a trend.

I can't really see the trend given that, for system time, your
pfn_valid_within results have a variance of ~9 and the early_pfn_valid
results have a variance of ~92. Given that the variance seems to come
about due to the reboots, I think we need more numbers to establish whether
the data sets end up largely overlapping or if they really are disjoint.

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
