Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id AADF16B0032
	for <linux-mm@kvack.org>; Mon, 20 Apr 2015 02:48:54 -0400 (EDT)
Received: by pdea3 with SMTP id a3so198593977pde.3
        for <linux-mm@kvack.org>; Sun, 19 Apr 2015 23:48:54 -0700 (PDT)
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id y1si12950256pdg.253.2015.04.19.23.48.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 19 Apr 2015 23:48:53 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NN300GXZEXDUA30@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 20 Apr 2015 07:48:49 +0100 (BST)
Message-id: <5534A14E.5010507@samsung.com>
Date: Mon, 20 Apr 2015 09:48:46 +0300
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH 2/2] arm64: add KASan support
References: <1427208544-8232-1-git-send-email-a.ryabinin@samsung.com>
 <1427208544-8232-3-git-send-email-a.ryabinin@samsung.com>
 <20150401122843.GA28616@e104818-lin.cambridge.arm.com>
 <551E993E.5060801@samsung.com> <552DCED9.40207@codeaurora.org>
 <552EA835.5070704@samsung.com> <5531537C.1000107@codeaurora.org>
In-reply-to: <5531537C.1000107@codeaurora.org>
Content-type: text/plain; charset=windows-1252
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Keitel <dkeitel@codeaurora.org>
Cc: Catalin Marinas <catalin.marinas@arm.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org

On 04/17/2015 09:39 PM, David Keitel wrote:
> On 04/15/2015 11:04 AM, Andrey Ryabinin wrote:
>> I've pushed the most fresh thing that I have in git:
>> 	git://github.com/aryabinin/linux.git kasan/arm64v1
>>
>> It's the same patches with two simple but important fixes on top of it.
> 
> Thanks, the two commits do fix compilation issues that I've had worked around to get to my mapping question.
> 
> I've addressed the mapping problem using __create_page_tables in arch/arm64/head.S as an example.
> 
> The next roadblock I hit was running into kasan_report_error calls in cgroups_early_init. After a short investigation it does seem to be a false positive due the the kasan_zero_page size and tracking bytes being reused for different memory regions.
> 
> I worked around that by enabling kasan error reporting only after the kasan_init is run. This let me get to the shell with some real KAsan reports along the way.

Reporting already disabled before kasan_init() and the last thing that kasan_init() is enable error reports.
So, how did you managed to get kasan's report before kasan_init()?

> There were some other fixes and hacks to get there. I'll backtrack to evaluate which ones warrant an RFC.
> 
>  - David
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
