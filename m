Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f174.google.com (mail-ie0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 9797D6B0032
	for <linux-mm@kvack.org>; Fri, 17 Apr 2015 14:39:59 -0400 (EDT)
Received: by iedfl3 with SMTP id fl3so88984712ied.1
        for <linux-mm@kvack.org>; Fri, 17 Apr 2015 11:39:59 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id dz5si10880022icb.102.2015.04.17.11.39.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Apr 2015 11:39:59 -0700 (PDT)
Message-ID: <5531537C.1000107@codeaurora.org>
Date: Fri, 17 Apr 2015 11:39:56 -0700
From: David Keitel <dkeitel@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] arm64: add KASan support
References: <1427208544-8232-1-git-send-email-a.ryabinin@samsung.com> <1427208544-8232-3-git-send-email-a.ryabinin@samsung.com> <20150401122843.GA28616@e104818-lin.cambridge.arm.com> <551E993E.5060801@samsung.com> <552DCED9.40207@codeaurora.org> <552EA835.5070704@samsung.com>
In-Reply-To: <552EA835.5070704@samsung.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org

On 04/15/2015 11:04 AM, Andrey Ryabinin wrote:
> I've pushed the most fresh thing that I have in git:
> 	git://github.com/aryabinin/linux.git kasan/arm64v1
> 
> It's the same patches with two simple but important fixes on top of it.

Thanks, the two commits do fix compilation issues that I've had worked around to get to my mapping question.

I've addressed the mapping problem using __create_page_tables in arch/arm64/head.S as an example.

The next roadblock I hit was running into kasan_report_error calls in cgroups_early_init. After a short investigation it does seem to be a false positive due the the kasan_zero_page size and tracking bytes being reused for different memory regions.

I worked around that by enabling kasan error reporting only after the kasan_init is run. This let me get to the shell with some real KAsan reports along the way. There were some other fixes and hacks to get there. I'll backtrack to evaluate which ones warrant an RFC.

 - David

-- 
Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
a Linux Foundation Collaborative Project

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
