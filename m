Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1887F6B0253
	for <linux-mm@kvack.org>; Tue,  3 Jan 2017 17:09:38 -0500 (EST)
Received: by mail-vk0-f72.google.com with SMTP id h67so237461786vkf.4
        for <linux-mm@kvack.org>; Tue, 03 Jan 2017 14:09:38 -0800 (PST)
Received: from mail-ua0-x229.google.com (mail-ua0-x229.google.com. [2607:f8b0:400c:c08::229])
        by mx.google.com with ESMTPS id x68si17573697vka.43.2017.01.03.14.09.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jan 2017 14:09:37 -0800 (PST)
Received: by mail-ua0-x229.google.com with SMTP id 88so329516014uaq.3
        for <linux-mm@kvack.org>; Tue, 03 Jan 2017 14:09:37 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <21511994.eBlbEPoKOz@wuerfel>
References: <20161227015413.187403-1-kirill.shutemov@linux.intel.com>
 <3492795.xaneWtGxgW@wuerfel> <CALCETrUCdu3kTBU09gXaSppO7VCm+872zkGnovaZKTXBbY2wTg@mail.gmail.com>
 <21511994.eBlbEPoKOz@wuerfel>
From: Andy Lutomirski <luto@amacapital.net>
Date: Tue, 3 Jan 2017 14:09:16 -0800
Message-ID: <CALCETrXmdAnbgjsxw=qTbP2PhVCzE8v3y5XMt8DVa4P9DowsGA@mail.gmail.com>
Subject: Re: [RFC, PATCHv2 29/29] mm, x86: introduce RLIMIT_VADDR
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, X86 ML <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, linux-arch <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>

On Tue, Jan 3, 2017 at 2:07 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> On Tuesday, January 3, 2017 10:29:33 AM CET Andy Lutomirski wrote:
>>
>> Hmm.  What if we approached this a bit differently?  We could add a
>> single new personality bit ADDR_LIMIT_EXPLICIT.  Setting this bit
>> cause PER_LINUX32_3GB etc to be automatically cleared.
>
> Both the ADDR_LIMIT_32BIT and ADDR_LIMIT_3GB flags I guess?

Yes.

>
>> When
>> ADDR_LIMIT_EXPLICIT is in effect, prctl can set a 64-bit numeric
>> limit.  If ADDR_LIMIT_EXPLICIT is cleared, the prctl value stops being
>> settable and reading it via prctl returns whatever is implied by the
>> other personality bits.
>
> I don't see anything wrong with it, but I'm a bit confused now
> what this would be good for, compared to using just prctl.
>
> Is this about setuid clearing the personality but not the prctl,
> or something else?

It's to avid ambiguity as to what happens if you set ADDR_LIMIT_32BIT
and use the prctl.  ISTM it would be nice for the semantics to be
fully defined in all cases.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
