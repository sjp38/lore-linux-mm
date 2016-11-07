Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3E18A6B0038
	for <linux-mm@kvack.org>; Mon,  7 Nov 2016 13:28:01 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id p190so66470633wmp.3
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 10:28:01 -0800 (PST)
Received: from pandora.armlinux.org.uk (pandora.armlinux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id f10si30898145wjl.93.2016.11.07.10.27.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 07 Nov 2016 10:27:59 -0800 (PST)
Date: Mon, 7 Nov 2016 18:27:35 +0000
From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH] arm/vdso: introduce vdso_mremap hook
Message-ID: <20161107182734.GL1041@n2100.armlinux.org.uk>
References: <20161101172214.2938-1-dsafonov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161101172214.2938-1-dsafonov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <dsafonov@virtuozzo.com>
Cc: linux-kernel@vger.kernel.org, 0x7f454c46@gmail.com, Kevin Brodsky <kevin.brodsky@arm.com>, Christopher Covington <cov@codeaurora.org>, Andy Lutomirski <luto@amacapital.net>, Oleg Nesterov <oleg@redhat.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Cyrill Gorcunov <gorcunov@openvz.org>, Pavel Emelyanov <xemul@virtuozzo.com>

On Tue, Nov 01, 2016 at 08:22:14PM +0300, Dmitry Safonov wrote:
> diff --git a/arch/arm/kernel/vdso.c b/arch/arm/kernel/vdso.c
> index 53cf86cf2d1a..d1001f87c2f6 100644
> --- a/arch/arm/kernel/vdso.c
> +++ b/arch/arm/kernel/vdso.c
> @@ -54,8 +54,11 @@ static const struct vm_special_mapping vdso_data_mapping = {
>  	.pages = &vdso_data_page,
>  };
>  
> +static int vdso_mremap(const struct vm_special_mapping *sm,
> +		struct vm_area_struct *new_vma);

I'd much rather avoid this forward declaration.  Is there any reason the
function body can't be here?

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
