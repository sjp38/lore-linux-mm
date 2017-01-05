Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id B81636B0069
	for <linux-mm@kvack.org>; Thu,  5 Jan 2017 06:03:23 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id v84so1067745071oie.0
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 03:03:23 -0800 (PST)
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-by2nam01on0060.outbound.protection.outlook.com. [104.47.34.60])
        by mx.google.com with ESMTPS id p73si18915005ota.228.2017.01.05.03.03.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 05 Jan 2017 03:03:23 -0800 (PST)
Date: Thu, 5 Jan 2017 12:03:04 +0100
From: Robert Richter <robert.richter@cavium.com>
Subject: Re: [PATCH v3] arm64: mm: Fix NOMAP page initialization
Message-ID: <20170105110304.GT4930@rric.localdomain>
References: <20161216165437.21612-1-rrichter@cavium.com>
 <CAKv+Gu_SmTNguC=tSCwYOL2kx-DogLvSYRZc56eGP=JhdrUOsA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <CAKv+Gu_SmTNguC=tSCwYOL2kx-DogLvSYRZc56eGP=JhdrUOsA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, David Daney <david.daney@cavium.com>, Mark Rutland <mark.rutland@arm.com>, Hanjun Guo <hanjun.guo@linaro.org>, James Morse <james.morse@arm.com>, Yisheng Xie <xieyisheng1@huawei.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 04.01.17 13:56:39, Ard Biesheuvel wrote:
> Given that you are touching arch/arm/ as well as arch/arm64, could you
> explain why only arm64 needs this treatment? Is it simply because we
> don't have NUMA support there?

I haven't considered a solution for arch/arm yet. The fixes are
independent. But if that fix would be an excepted solution, it could
be implemented for arm then too. But as you said, since probably only
NUMA is affected, we might not need it there.

-Robert

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
