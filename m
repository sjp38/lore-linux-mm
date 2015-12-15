Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 8B6846B0253
	for <linux-mm@kvack.org>; Tue, 15 Dec 2015 13:39:32 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id n186so178196604wmn.1
        for <linux-mm@kvack.org>; Tue, 15 Dec 2015 10:39:32 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id k185si4923163wmf.19.2015.12.15.10.39.31
        for <linux-mm@kvack.org>;
        Tue, 15 Dec 2015 10:39:31 -0800 (PST)
Date: Tue, 15 Dec 2015 19:39:24 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCHV2 3/3] x86, ras: Add mcsafe_memcpy() function to recover
 from machine checks
Message-ID: <20151215183924.GJ25973@pd.tnic>
References: <cover.1449861203.git.tony.luck@intel.com>
 <23b2515da9d06b198044ad83ca0a15ba38c24e6e.1449861203.git.tony.luck@intel.com>
 <20151215131135.GE25973@pd.tnic>
 <CAPcyv4gMr6LcZqjxt6fAoEiaa0AzcgMxnp2+V=TWJ1eHb6nC3A@mail.gmail.com>
 <3908561D78D1C84285E8C5FCA982C28F39F8566E@ORSMSX114.amr.corp.intel.com>
 <CAPcyv4icSmdnvQhsdzfP3uZYXJ2vsjrZxMQjSghNOt19u++o7g@mail.gmail.com>
 <CAPcyv4gMku=rAczAz2b4PaW6qwm9LAVU8BG3hcT_A4QMAkZfbA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CAPcyv4gMku=rAczAz2b4PaW6qwm9LAVU8BG3hcT_A4QMAkZfbA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86 ML <x86@kernel.org>

On Tue, Dec 15, 2015 at 10:35:49AM -0800, Dan Williams wrote:
> Correction we have MOVNTDQA, but that requires saving the fpu state
> and marking the memory as WC, i.e. probably not worth it.

Not really. Last time I tried an SSE3 memcpy in the kernel like glibc
does, it wasn't worth it. The enhanced REP; MOVSB is hands down faster.

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
