Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3AB906B025E
	for <linux-mm@kvack.org>; Thu,  5 Jan 2017 06:24:23 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id u5so1046903211pgi.7
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 03:24:23 -0800 (PST)
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (mail-sn1nam01on0044.outbound.protection.outlook.com. [104.47.32.44])
        by mx.google.com with ESMTPS id z30si43650298plh.61.2017.01.05.03.24.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 05 Jan 2017 03:24:22 -0800 (PST)
Date: Thu, 5 Jan 2017 12:24:07 +0100
From: Robert Richter <robert.richter@cavium.com>
Subject: Re: [PATCH 2/2] arm64: mm: enable CONFIG_HOLES_IN_ZONE for NUMA
Message-ID: <20170105112407.GU4930@rric.localdomain>
References: <1481706707-6211-1-git-send-email-ard.biesheuvel@linaro.org>
 <1481706707-6211-3-git-send-email-ard.biesheuvel@linaro.org>
 <20170104132831.GD18193@arm.com>
 <CAKv+Gu8MdpVDCSjfum7AMtbgR6cTP5H+67svhDSu6bkaijvvyg@mail.gmail.com>
 <20170104140223.GF18193@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170104140223.GF18193@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Catalin Marinas <catalin.marinas@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Hanjun Guo <hanjun.guo@linaro.org>, Yisheng Xie <xieyisheng1@huawei.com>, James Morse <james.morse@arm.com>

On 04.01.17 14:02:23, Will Deacon wrote:
> Using early_pfn_valid feels like a bodge to me, since having pfn_valid
> return false for something that early_pfn_valid says is valid (and is
> therefore initialised in the memmap) makes the NOMAP semantics even more
> confusing.

The concern I have had with HOLES_IN_ZONE is that it enables
pfn_valid_within() for arm64. This means that each pfn of a section is
checked which is done only once for the section otherwise. With up to
2^18 pages per section we traverse the memblock list by that factor
more often. There could be a performance regression. I haven't numbers
yet, since the fix causes another kernel crash. And, this is the next
problem I have. The crash doesn't happen otherwise. So, either it
uncovers another bug or the fix is incomplete. Though the changes look
like it should work. This needs more investigation.

-Robert

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
