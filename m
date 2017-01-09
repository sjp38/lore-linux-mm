Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id B1ABA6B0038
	for <linux-mm@kvack.org>; Mon,  9 Jan 2017 06:53:36 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id j82so97660763oih.6
        for <linux-mm@kvack.org>; Mon, 09 Jan 2017 03:53:36 -0800 (PST)
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-by2nam01on0049.outbound.protection.outlook.com. [104.47.34.49])
        by mx.google.com with ESMTPS id u74si3529155oif.122.2017.01.09.03.53.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 09 Jan 2017 03:53:36 -0800 (PST)
Date: Mon, 9 Jan 2017 12:53:20 +0100
From: Robert Richter <robert.richter@cavium.com>
Subject: Re: [PATCH v3] arm64: mm: Fix NOMAP page initialization
Message-ID: <20170109115320.GI4930@rric.localdomain>
References: <20161216165437.21612-1-rrichter@cavium.com>
 <CAKv+Gu_SmTNguC=tSCwYOL2kx-DogLvSYRZc56eGP=JhdrUOsA@mail.gmail.com>
 <c74d6ec6-16ba-dccc-3b0d-a8bedcb46dc5@linaro.org>
 <cbbf14fd-a1cc-2463-ba67-acd6d61e9db1@linaro.org>
 <CAKv+Gu8-+0LUTN0+8OGWRhd22Ls5cMQqTJcjKQK_0N=Uc-0jog@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <CAKv+Gu8-+0LUTN0+8OGWRhd22Ls5cMQqTJcjKQK_0N=Uc-0jog@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: Hanjun Guo <hanjun.guo@linaro.org>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, David Daney <david.daney@cavium.com>, Mark Rutland <mark.rutland@arm.com>, James Morse <james.morse@arm.com>, Yisheng Xie <xieyisheng1@huawei.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 06.01.17 08:37:25, Ard Biesheuvel wrote:
> Any comments on the performance impact (including boot time) ?

I did a kernel compile test and kernel mode time increases by about
2.2%. Though this is already significant, we need a more suitable mem
benchmark here for further testing.

For boot time I dont see significant changes.

-Robert


Boot times:

pfn_valid_within():
[   25.929134]
[   25.548830]
[   25.503225]

early_pfn_valid() v3:
[   25.773814]
[   25.548428]
[   25.765290]


Kernel compile times (3 runs each):

pfn_valid_within():

real    6m4.088s
user    372m57.607s
sys     16m55.158s

real    6m1.532s
user    372m48.453s
sys     16m50.370s

real    6m4.061s
user    373m18.753s
sys     16m57.027s


early_pfn_valid() v3:

real    6m3.261s
user    373m15.816s
sys     16m30.019s

real    6m2.980s
user    373m9.019s
sys     16m32.992s

real    6m2.574s
user    372m45.146s
sys     16m33.218s

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
