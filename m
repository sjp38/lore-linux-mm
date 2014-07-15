Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f179.google.com (mail-lb0-f179.google.com [209.85.217.179])
	by kanga.kvack.org (Postfix) with ESMTP id D7C946B0036
	for <linux-mm@kvack.org>; Tue, 15 Jul 2014 15:57:19 -0400 (EDT)
Received: by mail-lb0-f179.google.com with SMTP id v6so1572547lbi.10
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 12:57:19 -0700 (PDT)
Received: from mail-lb0-f172.google.com (mail-lb0-f172.google.com [209.85.217.172])
        by mx.google.com with ESMTPS id jb6si31333808lbc.32.2014.07.15.12.57.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 15 Jul 2014 12:57:18 -0700 (PDT)
Received: by mail-lb0-f172.google.com with SMTP id z11so1549043lbi.17
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 12:57:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1405452884-25688-4-git-send-email-toshi.kani@hp.com>
References: <1405452884-25688-1-git-send-email-toshi.kani@hp.com> <1405452884-25688-4-git-send-email-toshi.kani@hp.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Tue, 15 Jul 2014 12:56:57 -0700
Message-ID: <CALCETrUPpP1Lo1gB_eTm6V3pJ3Fam-1gPZGKfksOXXGgtNGsEQ@mail.gmail.com>
Subject: Re: [RFC PATCH 3/11] x86, mm, pat: Change reserve_memtype() to handle
 WT type
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, plagnioj@jcrosoft.com, tomi.valkeinen@ti.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Stefan Bader <stefan.bader@canonical.com>, Dave Airlie <airlied@gmail.com>, Borislav Petkov <bp@alien8.de>

On Tue, Jul 15, 2014 at 12:34 PM, Toshi Kani <toshi.kani@hp.com> wrote:
> This patch changes reserve_memtype() to handle the new WT type.
> When (!pat_enabled && new_type), it continues to set either WB
> or UC- to *new_type.  When pat_enabled, it can reserve a given
> non-RAM range for WT.  At this point, it may not reserve a RAM
> range for WT since reserve_ram_pages_type() uses the page flags
> limited to three memory types, WB, WC and UC.

FWIW, last time I looked at this, it seemed like all the fancy
reserve_ram_pages stuff was unnecessary: shouldn't the RAM type be
easy to track in the direct map page tables?

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
