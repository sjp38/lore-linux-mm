Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f47.google.com (mail-yh0-f47.google.com [209.85.213.47])
	by kanga.kvack.org (Postfix) with ESMTP id EA1536B0031
	for <linux-mm@kvack.org>; Tue, 15 Jul 2014 19:19:41 -0400 (EDT)
Received: by mail-yh0-f47.google.com with SMTP id f10so62795yha.34
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 16:19:41 -0700 (PDT)
Received: from g6t1525.atlanta.hp.com (g6t1525.atlanta.hp.com. [15.193.200.68])
        by mx.google.com with ESMTPS id r30si26844918yhm.123.2014.07.15.16.19.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 15 Jul 2014 16:19:41 -0700 (PDT)
Message-ID: <1405465801.28702.34.camel@misato.fc.hp.com>
Subject: Re: [RFC PATCH 3/11] x86, mm, pat: Change reserve_memtype() to
 handle WT type
From: Toshi Kani <toshi.kani@hp.com>
Date: Tue, 15 Jul 2014 17:10:01 -0600
In-Reply-To: <CALCETrUPpP1Lo1gB_eTm6V3pJ3Fam-1gPZGKfksOXXGgtNGsEQ@mail.gmail.com>
References: <1405452884-25688-1-git-send-email-toshi.kani@hp.com>
	 <1405452884-25688-4-git-send-email-toshi.kani@hp.com>
	 <CALCETrUPpP1Lo1gB_eTm6V3pJ3Fam-1gPZGKfksOXXGgtNGsEQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, plagnioj@jcrosoft.com, tomi.valkeinen@ti.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Stefan Bader <stefan.bader@canonical.com>, Dave Airlie <airlied@gmail.com>, Borislav Petkov <bp@alien8.de>

On Tue, 2014-07-15 at 12:56 -0700, Andy Lutomirski wrote:
> On Tue, Jul 15, 2014 at 12:34 PM, Toshi Kani <toshi.kani@hp.com> wrote:
> > This patch changes reserve_memtype() to handle the new WT type.
> > When (!pat_enabled && new_type), it continues to set either WB
> > or UC- to *new_type.  When pat_enabled, it can reserve a given
> > non-RAM range for WT.  At this point, it may not reserve a RAM
> > range for WT since reserve_ram_pages_type() uses the page flags
> > limited to three memory types, WB, WC and UC.
> 
> FWIW, last time I looked at this, it seemed like all the fancy
> reserve_ram_pages stuff was unnecessary: shouldn't the RAM type be
> easy to track in the direct map page tables?

Are you referring the direct map page tables as the kernel page
directory tables (pgd/pud/..)?

I think it needs to be able to keep track of the memory type per a
physical memory range, not per a translation, in order to prevent
aliasing of the memory type.

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
