Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id CA53F8E0001
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 08:01:20 -0500 (EST)
Received: by mail-wm1-f71.google.com with SMTP id l73so1586010wmb.1
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 05:01:20 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTPS id d69si32811907wmd.74.2019.01.21.05.01.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Jan 2019 05:01:19 -0800 (PST)
Date: Mon, 21 Jan 2019 14:01:11 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v7 11/25] ACPI / APEI: Move NOTIFY_SEA between the
 estatus-queue and NOTIFY_NMI
Message-ID: <20190121130111.GG29166@zn.tnic>
References: <20181203180613.228133-1-james.morse@arm.com>
 <20181203180613.228133-12-james.morse@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20181203180613.228133-12-james.morse@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Morse <james.morse@arm.com>
Cc: linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Fan Wu <wufan@codeaurora.org>

On Mon, Dec 03, 2018 at 06:05:59PM +0000, James Morse wrote:
> The estatus-queue code is currently hidden by the NOTIFY_NMI #ifdefs.
> Once NOTIFY_SEA starts using the estatus-queue we can stop hiding
> it as each architecture has a user that can't be turned off.
> 
> Split the existing CONFIG_HAVE_ACPI_APEI_NMI block in two, and move
> the SEA code into the gap.
> 
> This patch moves code around ... and changes the stale comment

s/This patch moves/Move the/

> describing why the status queue is necessary: printk() is no
> longer the issue, its the helpers like memory_failure_queue() that
> aren't nmi safe.
> 
> Signed-off-by: James Morse <james.morse@arm.com>
> ---
>  drivers/acpi/apei/ghes.c | 113 ++++++++++++++++++++-------------------
>  1 file changed, 59 insertions(+), 54 deletions(-)

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
