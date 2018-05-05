Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id F15DD6B000C
	for <linux-mm@kvack.org>; Sat,  5 May 2018 05:58:31 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id x2so1373577wmc.3
        for <linux-mm@kvack.org>; Sat, 05 May 2018 02:58:31 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTPS id s15-v6si15613458wrc.243.2018.05.05.02.58.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 05 May 2018 02:58:30 -0700 (PDT)
Date: Sat, 5 May 2018 11:58:05 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v3 01/12] ACPI / APEI: Move the estatus queue code up,
 and under its own ifdef
Message-ID: <20180505095805.GB3708@pd.tnic>
References: <20180427153510.5799-1-james.morse@arm.com>
 <20180427153510.5799-2-james.morse@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20180427153510.5799-2-james.morse@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Morse <james.morse@arm.com>
Cc: linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <cdall@kernel.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Punit Agrawal <punit.agrawal@arm.com>, jonathan.zhang@cavium.com

On Fri, Apr 27, 2018 at 04:34:59PM +0100, James Morse wrote:
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
> ---
>  drivers/acpi/apei/ghes.c | 265 ++++++++++++++++++++++++-----------------------
>  1 file changed, 137 insertions(+), 128 deletions(-)

Reviewed-by: Borislav Petkov <bp@suse.de>

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
