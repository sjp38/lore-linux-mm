Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 8E51E6B00A2
	for <linux-mm@kvack.org>; Wed, 18 Feb 2015 15:44:20 -0500 (EST)
Received: by mail-wi0-f182.google.com with SMTP id l15so4923771wiw.3
        for <linux-mm@kvack.org>; Wed, 18 Feb 2015 12:44:20 -0800 (PST)
Received: from mail-wi0-x22a.google.com (mail-wi0-x22a.google.com. [2a00:1450:400c:c05::22a])
        by mx.google.com with ESMTPS id hh1si37111139wib.9.2015.02.18.12.44.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Feb 2015 12:44:19 -0800 (PST)
Received: by mail-wi0-f170.google.com with SMTP id hi2so41522526wib.1
        for <linux-mm@kvack.org>; Wed, 18 Feb 2015 12:44:18 -0800 (PST)
Date: Wed, 18 Feb 2015 21:44:14 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v2 6/7] x86, mm: Support huge I/O mappings on x86
Message-ID: <20150218204414.GA20943@gmail.com>
References: <1423521935-17454-1-git-send-email-toshi.kani@hp.com>
 <1423521935-17454-7-git-send-email-toshi.kani@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1423521935-17454-7-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, arnd@arndb.de, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, Elliott@hp.com


* Toshi Kani <toshi.kani@hp.com> wrote:

> This patch implements huge I/O mapping capability interfaces on x86.

> +#ifdef CONFIG_HUGE_IOMAP
> +#ifdef CONFIG_X86_64
> +#define IOREMAP_MAX_ORDER       (PUD_SHIFT)
> +#else
> +#define IOREMAP_MAX_ORDER       (PMD_SHIFT)
> +#endif
> +#endif  /* CONFIG_HUGE_IOMAP */

> +#ifdef CONFIG_HUGE_IOMAP

Hm, so why is there a Kconfig option for this? It just 
complicates things.

For example the kernel already defaults to mapping itself 
with as large mappings as possible, without a Kconfig entry 
for it. There's no reason to make this configurable - and 
quite a bit of complexity in the patches comes from this 
configurability.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
