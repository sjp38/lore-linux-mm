Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 75CA26B0005
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 11:55:10 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id u13-v6so11157358oif.0
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 08:55:10 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id w11-v6si4257763oib.307.2018.04.24.08.55.09
        for <linux-mm@kvack.org>;
        Tue, 24 Apr 2018 08:55:09 -0700 (PDT)
Date: Tue, 24 Apr 2018 16:55:05 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH] kmemleak: Report if we need to tune
 KMEMLEAK_EARLY_LOG_SIZE
Message-ID: <20180424155504.frbxmzq4dw3veudu@armageddon.cambridge.arm.com>
References: <288b0afc-bcc3-a2aa-2791-707e625d1da7@siemens.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <288b0afc-bcc3-a2aa-2791-707e625d1da7@siemens.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kiszka <jan.kiszka@siemens.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, Apr 24, 2018 at 05:51:15PM +0200, Jan Kiszka wrote:
> ...rather than just mysteriously disabling it.
> 
> Signed-off-by: Jan Kiszka <jan.kiszka@siemens.com>
> ---
>  mm/kmemleak.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/mm/kmemleak.c b/mm/kmemleak.c
> index 9a085d525bbc..156c0c69cc5c 100644
> --- a/mm/kmemleak.c
> +++ b/mm/kmemleak.c
> @@ -863,6 +863,7 @@ static void __init log_early(int op_type, const void *ptr, size_t size,
>  
>  	if (crt_early_log >= ARRAY_SIZE(early_log)) {
>  		crt_early_log++;
> +		pr_warn("Too many early logs\n");

That's already printed, though later where we have an idea of how big the early
log needs to be:

	if (crt_early_log > ARRAY_SIZE(early_log))
		pr_warn("Early log buffer exceeded (%d), please increase DEBUG_KMEMLEAK_EARLY_LOG_SIZE\n",
			crt_early_log);

-- 
Catalin
