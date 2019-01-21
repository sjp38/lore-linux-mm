Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1E7D78E0001
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 08:35:48 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id y7so10766696wrr.12
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 05:35:48 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTPS id b6si27623214wrp.431.2019.01.21.05.35.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Jan 2019 05:35:46 -0800 (PST)
Date: Mon, 21 Jan 2019 14:35:40 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v7 17/25] ACPI / APEI: Pass ghes and estatus separately
 to avoid a later copy
Message-ID: <20190121133539.GH29166@zn.tnic>
References: <20181203180613.228133-1-james.morse@arm.com>
 <20181203180613.228133-18-james.morse@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20181203180613.228133-18-james.morse@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Morse <james.morse@arm.com>
Cc: linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Fan Wu <wufan@codeaurora.org>

On Mon, Dec 03, 2018 at 06:06:05PM +0000, James Morse wrote:
> The NMI-like notifications scribble over ghes->estatus, before
> copying it somewhere else. If this interrupts the ghes_probe() code
> calling ghes_proc() on each struct ghes, the data is corrupted.
> 
> All the NMI-like notifications should use a queued estatus entry
> from the beginning, instead of the ghes version, then copying it.
> To do this, break up any use of "ghes->estatus" so that all
> functions take the estatus as an argument.
> 
> This patch just moves these ghes->estatus dereferences into separate

s/This patch just moves/Move/

> arguments, no change in behaviour. struct ghes becomes unused in
> ghes_clear_estatus() as it only wanted ghes->estatus, which we now
> pass directly. This is removed.
> 
> Signed-off-by: James Morse <james.morse@arm.com>

...

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
