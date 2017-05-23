Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id B00776B02B4
	for <linux-mm@kvack.org>; Tue, 23 May 2017 05:21:20 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id d14so61822436qkb.0
        for <linux-mm@kvack.org>; Tue, 23 May 2017 02:21:20 -0700 (PDT)
Received: from mail-qt0-x244.google.com (mail-qt0-x244.google.com. [2607:f8b0:400d:c0d::244])
        by mx.google.com with ESMTPS id x186si21083559qke.166.2017.05.23.02.21.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 May 2017 02:21:19 -0700 (PDT)
Received: by mail-qt0-x244.google.com with SMTP id j13so21443073qta.3
        for <linux-mm@kvack.org>; Tue, 23 May 2017 02:21:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170523040524.13717-6-oohall@gmail.com>
References: <20170523040524.13717-1-oohall@gmail.com> <20170523040524.13717-6-oohall@gmail.com>
From: Balbir Singh <bsingharora@gmail.com>
Date: Tue, 23 May 2017 19:21:19 +1000
Message-ID: <CAKTCnzkhf_6N6TPVcGZo8C_yuJtuhZbU0=LdaNa3Ec7dEQsmVQ@mail.gmail.com>
Subject: Re: [PATCH 6/6] powerpc/mm: Enable ZONE_DEVICE on powerpc
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oliver O'Halloran <oohall@gmail.com>
Cc: "open list:LINUX FOR POWERPC (32-BIT AND 64-BIT)" <linuxppc-dev@lists.ozlabs.org>, linux-mm <linux-mm@kvack.org>

On Tue, May 23, 2017 at 2:05 PM, Oliver O'Halloran <oohall@gmail.com> wrote:
> Flip the switch. Running around and screaming "IT'S ALIVE" is optional,
> but recommended.
>
> Signed-off-by: Oliver O'Halloran <oohall@gmail.com>
> ---
>  arch/powerpc/Kconfig | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
> index f7c8f9972f61..bf3365c34244 100644
> --- a/arch/powerpc/Kconfig
> +++ b/arch/powerpc/Kconfig
> @@ -138,6 +138,7 @@ config PPC
>         select ARCH_HAS_SG_CHAIN
>         select ARCH_HAS_TICK_BROADCAST          if GENERIC_CLOCKEVENTS_BROADCAST
>         select ARCH_HAS_UBSAN_SANITIZE_ALL
> +       select ARCH_HAS_ZONE_DEVICE             if PPC64

Does this work for Book E as well?

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
