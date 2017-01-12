Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id EE1086B0033
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 13:58:41 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id y143so68257336pfb.6
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 10:58:41 -0800 (PST)
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-by2nam01on0057.outbound.protection.outlook.com. [104.47.34.57])
        by mx.google.com with ESMTPS id 44si10064710plc.225.2017.01.12.10.58.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 12 Jan 2017 10:58:41 -0800 (PST)
Date: Thu, 12 Jan 2017 19:58:25 +0100
From: Robert Richter <robert.richter@cavium.com>
Subject: Re: [PATCH v3] arm64: mm: Fix NOMAP page initialization
Message-ID: <20170112185825.GE5020@rric.localdomain>
References: <20161216165437.21612-1-rrichter@cavium.com>
 <CAKv+Gu_SmTNguC=tSCwYOL2kx-DogLvSYRZc56eGP=JhdrUOsA@mail.gmail.com>
 <c74d6ec6-16ba-dccc-3b0d-a8bedcb46dc5@linaro.org>
 <cbbf14fd-a1cc-2463-ba67-acd6d61e9db1@linaro.org>
 <CAKv+Gu8-+0LUTN0+8OGWRhd22Ls5cMQqTJcjKQK_0N=Uc-0jog@mail.gmail.com>
 <20170109115320.GI4930@rric.localdomain>
 <20170112160535.GF13843@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170112160535.GF13843@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>, Hanjun Guo <hanjun.guo@linaro.org>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, David Daney <david.daney@cavium.com>, Mark Rutland <mark.rutland@arm.com>, James Morse <james.morse@arm.com>, Yisheng Xie <xieyisheng1@huawei.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 12.01.17 16:05:36, Will Deacon wrote:
> On Mon, Jan 09, 2017 at 12:53:20PM +0100, Robert Richter wrote:

> > Kernel compile times (3 runs each):
> > 
> > pfn_valid_within():
> > 
> > real    6m4.088s
> > user    372m57.607s
> > sys     16m55.158s
> > 
> > real    6m1.532s
> > user    372m48.453s
> > sys     16m50.370s
> > 
> > real    6m4.061s
> > user    373m18.753s
> > sys     16m57.027s
> 
> Did you reboot the machine between each build here, or only when changing
> kernel? If the latter, do you see variations in kernel build time by simply
> rebooting the same Image?

I built it in a loop on the shell, so no reboots between builds. Note
that I was building the kernel in /dev/shm to not access harddisks. I
think build times should be comparable then since there is no fs
caching.

-Robert

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
