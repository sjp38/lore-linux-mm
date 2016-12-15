Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 18EF96B0253
	for <linux-mm@kvack.org>; Thu, 15 Dec 2016 10:48:59 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id 81so68005160iog.0
        for <linux-mm@kvack.org>; Thu, 15 Dec 2016 07:48:59 -0800 (PST)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0071.outbound.protection.outlook.com. [104.47.33.71])
        by mx.google.com with ESMTPS id u23si2558563ite.69.2016.12.15.07.48.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 15 Dec 2016 07:48:58 -0800 (PST)
Date: Thu, 15 Dec 2016 16:48:45 +0100
From: Robert Richter <robert.richter@cavium.com>
Subject: Re: [PATCH] arm64: mm: Fix NOMAP page initialization
Message-ID: <20161215154845.GB8111@rric.localdomain>
References: <1481307042-29773-1-git-send-email-rrichter@cavium.com>
 <83d6e6d0-cfb3-ec8b-241b-ec6a50dc2aa9@huawei.com>
 <9168b603-04aa-4302-3197-00f17fb336bd@huawei.com>
 <20161214094542.GE5588@rric.localdomain>
 <4bc9df75-1b67-2428-184e-ce52b5f95528@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <4bc9df75-1b67-2428-184e-ce52b5f95528@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yisheng Xie <xieyisheng1@huawei.com>
Cc: Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, David Daney <david.daney@cavium.com>, Mark Rutland <mark.rutland@arm.com>, Hanjun Guo <hanjun.guo@linaro.org>, James Morse <james.morse@arm.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hanjun Guo <guohanjun@huawei.com>, Xishi Qiu <qiuxishi@huawei.com>

On 15.12.16 11:01:04, Yisheng Xie wrote:
> > I sent a V2 patch that uses pfn_present(). This only initilizes
> > sections with memory.
> hmmi 1/4 ? maybe I do not quite catch what your mean, but I do not think
> pfn_present is right for this case.
> 
> IMO, The valid_section() means the section with mem_map, not section with memory.

Right, the section may be uninitialized with the present flag only.
valid_section() is better, this is also the pfn_valid() default
implementation.

Will rework. Thanks.

-Robert

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
