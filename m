Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id C39246B0005
	for <linux-mm@kvack.org>; Tue,  1 May 2018 06:43:23 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id 7-v6so3261741oin.16
        for <linux-mm@kvack.org>; Tue, 01 May 2018 03:43:23 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id l18-v6si3581697otk.130.2018.05.01.03.43.22
        for <linux-mm@kvack.org>;
        Tue, 01 May 2018 03:43:22 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: Re: [PATCH v3 01/12] ACPI / APEI: Move the estatus queue code up, and under its own ifdef
References: <20180427153510.5799-1-james.morse@arm.com>
	<20180427153510.5799-2-james.morse@arm.com>
Date: Tue, 01 May 2018 11:43:19 +0100
In-Reply-To: <20180427153510.5799-2-james.morse@arm.com> (James Morse's
	message of "Fri, 27 Apr 2018 16:34:59 +0100")
Message-ID: <877eonr708.fsf@e105922-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Morse <james.morse@arm.com>
Cc: linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <cdall@kernel.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, jonathan.zhang@cavium.com

Hi James,

James Morse <james.morse@arm.com> writes:

> To support asynchronous NMI-like notifications on arm64 we need to use
> the estatus-queue. These patches refactor it to allow multiple APEI
> notification types to use it.
>
> First we move the estatus-queue code higher in the file so that any
> notify_foo() handler can make use of it.
>
> This patch moves code around ... and makes the following trivial change:
> Freshen the dated comment above ghes_estatus_llist. printk() is no
> longer the issue, its the helpers like memory_failure_queue() that
> still aren't nmi safe.
>
> Signed-off-by: James Morse <james.morse@arm.com>
> Reviewed-by: Punit Agrawal <punit.agrawal@arm.com>
>


> Notes for cover letter:
> ghes.c has three things all called 'estatus'. One is a pool of memory
> that has a static size, and is grown/shrunk when new NMI users are
> allocated.
> The second is the cache, this holds recent notifications so we can
> suppress notifications we've already handled.
> The last is the queue, which hold data from NMI notifications (in pool
> memory) that can't be handled immediatly.


I am guessing you intended to drop the notes before sending the patch
out.

Calling this out as it'd make sense to clean-this up if the series is
ready for merging.

Thanks,
Punit

[...]
