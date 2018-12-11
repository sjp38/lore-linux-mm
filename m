Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 748CF8E0095
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 12:18:40 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id 18so923966wmw.6
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 09:18:40 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTPS id b84si400413wme.1.2018.12.11.09.18.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Dec 2018 09:18:39 -0800 (PST)
Date: Tue, 11 Dec 2018 18:18:30 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v7 07/25] ACPI / APEI: Remove spurious GHES_TO_CLEAR check
Message-ID: <20181211171830.GL27375@zn.tnic>
References: <20181203180613.228133-1-james.morse@arm.com>
 <20181203180613.228133-8-james.morse@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20181203180613.228133-8-james.morse@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Morse <james.morse@arm.com>
Cc: linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Fan Wu <wufan@codeaurora.org>

On Mon, Dec 03, 2018 at 06:05:55PM +0000, James Morse wrote:
> ghes_notify_nmi() checks ghes->flags for GHES_TO_CLEAR before going
> on to __process_error(). This is pointless as ghes_read_estatus()
> will always set this flag if it returns success, which was checked
> earlier in the loop. Remove it.
> 
> Signed-off-by: James Morse <james.morse@arm.com>
> ---
>  drivers/acpi/apei/ghes.c | 3 ---
>  1 file changed, 3 deletions(-)
> 
> diff --git a/drivers/acpi/apei/ghes.c b/drivers/acpi/apei/ghes.c
> index acf0c37e9af9..f7a0ff1c785a 100644
> --- a/drivers/acpi/apei/ghes.c
> +++ b/drivers/acpi/apei/ghes.c
> @@ -936,9 +936,6 @@ static int ghes_notify_nmi(unsigned int cmd, struct pt_regs *regs)
>  			__ghes_panic(ghes);
>  		}
>  
> -		if (!(ghes->flags & GHES_TO_CLEAR))
> -			continue;
> -
>  		__process_error(ghes);
>  		ghes_clear_estatus(ghes, buf_paddr);
>  	}
> -- 

Reviewed-by: Borislav Petkov <bp@suse.de>

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
