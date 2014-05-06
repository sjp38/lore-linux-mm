Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 9092E6B0036
	for <linux-mm@kvack.org>; Tue,  6 May 2014 12:33:37 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id y13so7295155pdi.35
        for <linux-mm@kvack.org>; Tue, 06 May 2014 09:33:37 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id pb4si12262694pac.318.2014.05.06.09.33.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 May 2014 09:33:36 -0700 (PDT)
Message-ID: <53690EE6.2020909@codeaurora.org>
Date: Tue, 06 May 2014 09:33:42 -0700
From: Laura Abbott <lauraa@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [PATCHv5 2/2] arm: Get rid of meminfo
References: <1396544698-15596-1-git-send-email-lauraa@codeaurora.org> <1396544698-15596-3-git-send-email-lauraa@codeaurora.org> <20140501130849.C093DC409DA@trevor.secretlab.ca>
In-Reply-To: <20140501130849.C093DC409DA@trevor.secretlab.ca>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Grant Likely <grant.likely@secretlab.ca>, Russell King <linux@arm.linux.org.uk>, David Brown <davidb@codeaurora.org>, Daniel Walker <dwalker@fifo99.com>, Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>, Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>, Eric Miao <eric.y.miao@gmail.com>, Haojian Zhuang <haojian.zhuang@gmail.com>, Ben Dooks <ben-linux@fluff.org>, Kukjin Kim <kgene.kim@samsung.com>, linux-arm-kernel@lists.infradead.org
Cc: Nicolas Pitre <nicolas.pitre@linaro.org>, Courtney Cavin <courtney.cavin@sonymobile.com>, Grygorii Strashko <grygorii.strashko@ti.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, linux-arm-msm@vger.kernel.org, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, Leif Lindholm <leif.lindholm@linaro.org>, linux-mm@kvack.org, Catalin Marinas <catalin.marinas@arm.com>, Santosh Shilimkar <santosh.shilimkar@ti.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>

On 5/1/2014 6:08 AM, Grant Likely wrote:
> On Thu,  3 Apr 2014 10:04:58 -0700, Laura Abbott <lauraa@codeaurora.org> wrote:
>> memblock is now fully integrated into the kernel and is the prefered
>> method for tracking memory. Rather than reinvent the wheel with
>> meminfo, migrate to using memblock directly instead of meminfo as
>> an intermediate.
>>
>> Change-Id: I9d04e636f43bf939e13b4934dc23da0c076811d2
>> Acked-by: Jason Cooper <jason@lakedaemon.net>
>> Acked-by: Catalin Marinas <catalin.marinas@arm.com>
>> Acked-by: Santosh Shilimkar <santosh.shilimkar@ti.com>
>> Tested-by: Leif Lindholm <leif.lindholm@linaro.org>
>> Signed-off-by: Laura Abbott <lauraa@codeaurora.org>
> 
> Tested-by: Grant Likely <grant.likely@linaro.org>
> 
> Tiny nit-picking comment below, but this patch looks really good.
> What's the state on merging this?
> 

I put this into the patch system as 8025/1 a few weeks ago. I've been
busy/on vacation so I haven't had a chance to follow up since then.

Laura

-- 
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
