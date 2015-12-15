Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 988AF6B0254
	for <linux-mm@kvack.org>; Tue, 15 Dec 2015 14:28:46 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id l126so8655228wml.0
        for <linux-mm@kvack.org>; Tue, 15 Dec 2015 11:28:46 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id js6si3980438wjb.211.2015.12.15.11.28.45
        for <linux-mm@kvack.org>;
        Tue, 15 Dec 2015 11:28:45 -0800 (PST)
Date: Tue, 15 Dec 2015 20:28:37 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCHV2 3/3] x86, ras: Add mcsafe_memcpy() function to recover
 from machine checks
Message-ID: <20151215192837.GL25973@pd.tnic>
References: <cover.1449861203.git.tony.luck@intel.com>
 <23b2515da9d06b198044ad83ca0a15ba38c24e6e.1449861203.git.tony.luck@intel.com>
 <20151215131135.GE25973@pd.tnic>
 <CAPcyv4gMr6LcZqjxt6fAoEiaa0AzcgMxnp2+V=TWJ1eHb6nC3A@mail.gmail.com>
 <3908561D78D1C84285E8C5FCA982C28F39F8566E@ORSMSX114.amr.corp.intel.com>
 <CAPcyv4icSmdnvQhsdzfP3uZYXJ2vsjrZxMQjSghNOt19u++o7g@mail.gmail.com>
 <CAPcyv4gMku=rAczAz2b4PaW6qwm9LAVU8BG3hcT_A4QMAkZfbA@mail.gmail.com>
 <20151215183924.GJ25973@pd.tnic>
 <94D0CD8314A33A4D9D801C0FE68B40295BE9F290@G4W3202.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <94D0CD8314A33A4D9D801C0FE68B40295BE9F290@G4W3202.americas.hpqcorp.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Elliott, Robert (Persistent Memory)" <elliott@hpe.com>
Cc: Dan Williams <dan.j.williams@intel.com>, "Luck, Tony" <tony.luck@intel.com>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>

On Tue, Dec 15, 2015 at 07:19:58PM +0000, Elliott, Robert (Persistent Memory) wrote:

...

> Due to the historic long latency of storage devices,
> applications don't re-read from storage again; they
> save the results.
> So, the streaming-load instructions are beneficial:

That's the theory...

Do you also have some actual performance numbers where non-temporal
operations are better than the REP; MOVSB and *actually* show
improvements? And no microbenchmarks please.

Thanks.

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
