Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 10B6F6B0009
	for <linux-mm@kvack.org>; Fri, 23 Feb 2018 13:08:11 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id x97so5546011wrb.3
        for <linux-mm@kvack.org>; Fri, 23 Feb 2018 10:08:11 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTPS id 133si1704406wmr.89.2018.02.23.10.08.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Feb 2018 10:08:09 -0800 (PST)
Date: Fri, 23 Feb 2018 19:07:54 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH 01/11] ACPI / APEI: Move the estatus queue code up, and
 under its own ifdef
Message-ID: <20180223180754.GI4981@pd.tnic>
References: <20180215185606.26736-1-james.morse@arm.com>
 <20180215185606.26736-2-james.morse@arm.com>
 <20180220192852.GB24320@pd.tnic>
 <5A90572D.9010704@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <5A90572D.9010704@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Morse <james.morse@arm.com>
Cc: linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Christoffer Dall <christoffer.dall@linaro.org>, Marc Zyngier <marc.zyngier@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Punit Agrawal <punit.agrawal@arm.com>

On Fri, Feb 23, 2018 at 06:02:21PM +0000, James Morse wrote:
> Sure. I reckon your English grammar is better than mine, is this better?:

Bah, you must be joking :-)

> | In any NMI-like handler, memory from ghes_estatus_pool is used to save
> | estatus, and added to the ghes_estatus_llist. irq_work_queue() causes
> | ghes_proc_in_irq() to run in IRQ context where each estatus in
> | ghes_estatus_llist are processed. Each NMI-like error source must grow

s/are/is/ reads better to me, for some reason :)

> | the ghes_estatus_pool to ensure memory is available.

Other than that, yap, much better!

Thx.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
