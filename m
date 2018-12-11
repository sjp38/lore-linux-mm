Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1260A8E0095
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 11:54:19 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id z16so5094339wrt.5
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 08:54:19 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTPS id n6si9412133wrw.334.2018.12.11.08.54.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Dec 2018 08:54:17 -0800 (PST)
Date: Tue, 11 Dec 2018 17:54:14 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v7 05/25] ACPI / APEI: Make estatus pool allocation a
 static size
Message-ID: <20181211165414.GJ27375@zn.tnic>
References: <20181203180613.228133-1-james.morse@arm.com>
 <20181203180613.228133-6-james.morse@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20181203180613.228133-6-james.morse@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Morse <james.morse@arm.com>
Cc: linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Fan Wu <wufan@codeaurora.org>

On Mon, Dec 03, 2018 at 06:05:53PM +0000, James Morse wrote:
> Adding new NMI-like notifications duplicates the calls that grow
> and shrink the estatus pool. This is all pretty pointless, as the
> size is capped to 64K. Allocate this for each ghes and drop
> the code that grows and shrinks the pool.
> 
> Suggested-by: Borislav Petkov <bp@suse.de>
> Signed-off-by: James Morse <james.morse@arm.com>
> ---
>  drivers/acpi/apei/ghes.c | 49 +++++-----------------------------------
>  drivers/acpi/apei/hest.c |  2 +-
>  include/acpi/ghes.h      |  2 +-
>  3 files changed, 8 insertions(+), 45 deletions(-)

Nice and simple, cool. Thanks for doing that.

Reviewed-by: Borislav Petkov <bp@suse.de>

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
