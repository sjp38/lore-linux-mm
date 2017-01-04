Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id DF3AB6B0038
	for <linux-mm@kvack.org>; Wed,  4 Jan 2017 09:04:44 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id iq1so54773589wjb.1
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 06:04:44 -0800 (PST)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.17.10])
        by mx.google.com with ESMTPS id h188si77840187wma.91.2017.01.04.06.04.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jan 2017 06:04:43 -0800 (PST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC, PATCHv2 29/29] mm, x86: introduce RLIMIT_VADDR
Date: Wed, 04 Jan 2017 14:55:41 +0100
Message-ID: <5530270.v1BLsanhbo@wuerfel>
In-Reply-To: <CALCETrXmdAnbgjsxw=qTbP2PhVCzE8v3y5XMt8DVa4P9DowsGA@mail.gmail.com>
References: <20161227015413.187403-1-kirill.shutemov@linux.intel.com> <21511994.eBlbEPoKOz@wuerfel> <CALCETrXmdAnbgjsxw=qTbP2PhVCzE8v3y5XMt8DVa4P9DowsGA@mail.gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org
Cc: Andy Lutomirski <luto@amacapital.net>, linux-arch <linux-arch@vger.kernel.org>, Andi Kleen <ak@linux.intel.com>, Catalin Marinas <catalin.marinas@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, X86 ML <x86@kernel.org>, Will Deacon <will.deacon@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dave Hansen <dave.hansen@intel.com>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tuesday, January 3, 2017 2:09:16 PM CET Andy Lutomirski wrote:
> >
> >> When
> >> ADDR_LIMIT_EXPLICIT is in effect, prctl can set a 64-bit numeric
> >> limit.  If ADDR_LIMIT_EXPLICIT is cleared, the prctl value stops being
> >> settable and reading it via prctl returns whatever is implied by the
> >> other personality bits.
> >
> > I don't see anything wrong with it, but I'm a bit confused now
> > what this would be good for, compared to using just prctl.
> >
> > Is this about setuid clearing the personality but not the prctl,
> > or something else?
> 
> It's to avid ambiguity as to what happens if you set ADDR_LIMIT_32BIT
> and use the prctl.  ISTM it would be nice for the semantics to be
> fully defined in all cases.
> 

Ok, got it.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
