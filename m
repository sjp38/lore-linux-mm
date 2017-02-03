Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0F1E26B0069
	for <linux-mm@kvack.org>; Fri,  3 Feb 2017 10:14:30 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id s10so18220582itb.7
        for <linux-mm@kvack.org>; Fri, 03 Feb 2017 07:14:30 -0800 (PST)
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (mail-sn1nam01on0079.outbound.protection.outlook.com. [104.47.32.79])
        by mx.google.com with ESMTPS id d184si3709503iod.105.2017.02.03.07.14.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 03 Feb 2017 07:14:29 -0800 (PST)
Date: Fri, 3 Feb 2017 16:14:14 +0100
From: Robert Richter <robert.richter@cavium.com>
Subject: Re: [PATCH v3] arm64: mm: Fix NOMAP page initialization
Message-ID: <20170203151414.GE16822@rric.localdomain>
References: <c74d6ec6-16ba-dccc-3b0d-a8bedcb46dc5@linaro.org>
 <cbbf14fd-a1cc-2463-ba67-acd6d61e9db1@linaro.org>
 <CAKv+Gu8-+0LUTN0+8OGWRhd22Ls5cMQqTJcjKQK_0N=Uc-0jog@mail.gmail.com>
 <20170109115320.GI4930@rric.localdomain>
 <20170112160535.GF13843@arm.com>
 <20170112185825.GE5020@rric.localdomain>
 <20170113091903.GA22538@arm.com>
 <20170113131500.GS4930@rric.localdomain>
 <20170117100015.GG5020@rric.localdomain>
 <20170117191656.GS27328@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170117191656.GS27328@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>, Hanjun Guo <hanjun.guo@linaro.org>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, David Daney <david.daney@cavium.com>, Mark Rutland <mark.rutland@arm.com>, James Morse <james.morse@arm.com>, Yisheng Xie <xieyisheng1@huawei.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 17.01.17 19:16:56, Will Deacon wrote:
> I can't really see the trend given that, for system time, your
> pfn_valid_within results have a variance of ~9 and the early_pfn_valid
> results have a variance of ~92. Given that the variance seems to come
> about due to the reboots, I think we need more numbers to establish whether
> the data sets end up largely overlapping or if they really are disjoint.

Assuming the numbers of both versions are not significant, please
apply one or the other.

Thanks,

-Robert

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
