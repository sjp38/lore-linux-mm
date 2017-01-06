Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id A853C6B025E
	for <linux-mm@kvack.org>; Fri,  6 Jan 2017 07:03:41 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 17so850646403pfy.2
        for <linux-mm@kvack.org>; Fri, 06 Jan 2017 04:03:41 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id m6si48446306pgg.168.2017.01.06.04.03.40
        for <linux-mm@kvack.org>;
        Fri, 06 Jan 2017 04:03:40 -0800 (PST)
Date: Fri, 6 Jan 2017 12:03:40 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH 2/2] arm64: mm: enable CONFIG_HOLES_IN_ZONE for NUMA
Message-ID: <20170106120339.GA20726@arm.com>
References: <1481706707-6211-1-git-send-email-ard.biesheuvel@linaro.org>
 <1481706707-6211-3-git-send-email-ard.biesheuvel@linaro.org>
 <20170104132831.GD18193@arm.com>
 <CAKv+Gu8MdpVDCSjfum7AMtbgR6cTP5H+67svhDSu6bkaijvvyg@mail.gmail.com>
 <20170104140223.GF18193@arm.com>
 <20170105112407.GU4930@rric.localdomain>
 <20170105120819.GH679@arm.com>
 <20170105122200.GV4930@rric.localdomain>
 <20170105194944.GY4930@rric.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170105194944.GY4930@rric.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robert Richter <robert.richter@cavium.com>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Catalin Marinas <catalin.marinas@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Hanjun Guo <hanjun.guo@linaro.org>, Yisheng Xie <xieyisheng1@huawei.com>, James Morse <james.morse@arm.com>

On Thu, Jan 05, 2017 at 08:49:44PM +0100, Robert Richter wrote:
> On 05.01.17 13:22:00, Robert Richter wrote:
> > On 05.01.17 12:08:20, Will Deacon wrote:
> > > I really can't see how the fix causes a crash, and I couldn't reproduce
> > > it on any of my boards, nor could any of the Linaro folk afaik. Are you
> > > definitely running mainline with just these two patches from Ard?
> > 
> > Yes, just both patches applied. Various other solutions were working.
> 
> I have retested the same kernel (v4.9 based) as before and now it
> boots fine including rtc-efi device registration (it was crashing
> there):
> 
>  rtc-efi rtc-efi: rtc core: registered rtc-efi as rtc0
> 
> There could be a difference in firmware and mem setup, though I also
> downgraded the firmware to test it, but can't reproduce it anymore. I
> could reliable trigger the crash the first time.
> 
> FTR the oops.

Hmm, I just can't help but think you were accidentally running with
additional patches when you saw this oops previously. For example,
your log looks very similar to this one:

  http://lists.infradead.org/pipermail/linux-arm-kernel/2016-December/473666.html

but then again, these crashes probably often look alike.

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
