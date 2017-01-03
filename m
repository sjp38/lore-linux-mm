Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 01F516B0069
	for <linux-mm@kvack.org>; Tue,  3 Jan 2017 17:07:32 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id iq1so51817592wjb.1
        for <linux-mm@kvack.org>; Tue, 03 Jan 2017 14:07:31 -0800 (PST)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.126.130])
        by mx.google.com with ESMTPS id e70si75078584wmc.129.2017.01.03.14.07.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jan 2017 14:07:30 -0800 (PST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC, PATCHv2 29/29] mm, x86: introduce RLIMIT_VADDR
Date: Tue, 03 Jan 2017 23:07:20 +0100
Message-ID: <21511994.eBlbEPoKOz@wuerfel>
In-Reply-To: <CALCETrUCdu3kTBU09gXaSppO7VCm+872zkGnovaZKTXBbY2wTg@mail.gmail.com>
References: <20161227015413.187403-1-kirill.shutemov@linux.intel.com> <3492795.xaneWtGxgW@wuerfel> <CALCETrUCdu3kTBU09gXaSppO7VCm+872zkGnovaZKTXBbY2wTg@mail.gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, X86 ML <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, linux-arch <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>

On Tuesday, January 3, 2017 10:29:33 AM CET Andy Lutomirski wrote:
> 
> Hmm.  What if we approached this a bit differently?  We could add a
> single new personality bit ADDR_LIMIT_EXPLICIT.  Setting this bit
> cause PER_LINUX32_3GB etc to be automatically cleared.

Both the ADDR_LIMIT_32BIT and ADDR_LIMIT_3GB flags I guess?

> When
> ADDR_LIMIT_EXPLICIT is in effect, prctl can set a 64-bit numeric
> limit.  If ADDR_LIMIT_EXPLICIT is cleared, the prctl value stops being
> settable and reading it via prctl returns whatever is implied by the
> other personality bits.

I don't see anything wrong with it, but I'm a bit confused now
what this would be good for, compared to using just prctl.

Is this about setuid clearing the personality but not the prctl,
or something else?

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
