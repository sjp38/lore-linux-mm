Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id D36556B6E7A
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 06:36:09 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id w4so12943510wrt.21
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 03:36:09 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTPS id m1si8246609wmm.79.2018.12.04.03.36.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 03:36:08 -0800 (PST)
Date: Tue, 4 Dec 2018 12:36:01 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v7 02/25] ACPI / APEI: Remove silent flag from
 ghes_read_estatus()
Message-ID: <20181204113601.GB11803@zn.tnic>
References: <20181203180613.228133-1-james.morse@arm.com>
 <20181203180613.228133-3-james.morse@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20181203180613.228133-3-james.morse@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Morse <james.morse@arm.com>
Cc: linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Fan Wu <wufan@codeaurora.org>

On Mon, Dec 03, 2018 at 06:05:50PM +0000, James Morse wrote:
> Subsequent patches will split up ghes_read_estatus(), at which
> point passing around the 'silent' flag gets annoying. This is to
> suppress prink() messages, which prior to commit 42a0bb3f7138
> ("printk/nmi: generic solution for safe printk in NMI"), were
> unsafe in NMI context.
> 
> This is no longer necessary, remove the flag. printk() messages
> are batched in a per-cpu buffer and printed via irq-work, or a call
> back from panic().
> 
> Signed-off-by: James Morse <james.morse@arm.com>
> ---
> Changes since v6:
>  * Moved earlier in the series,
>  * Tinkered with the commit message.
>  * switched to pr_warn_ratelimited() to shut checkpatch up
> 
> shutup checkpatch
> ---
>  drivers/acpi/apei/ghes.c | 15 +++++++--------
>  1 file changed, 7 insertions(+), 8 deletions(-)

Reviewed-by: Borislav Petkov <bp@suse.de>

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
