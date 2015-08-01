Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f173.google.com (mail-io0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id 7E7EB6B0038
	for <linux-mm@kvack.org>; Sat,  1 Aug 2015 12:39:08 -0400 (EDT)
Received: by ioea135 with SMTP id a135so111579337ioe.1
        for <linux-mm@kvack.org>; Sat, 01 Aug 2015 09:39:08 -0700 (PDT)
Received: from mail-ig0-x232.google.com (mail-ig0-x232.google.com. [2607:f8b0:4001:c05::232])
        by mx.google.com with ESMTPS id b17si9910700ioj.5.2015.08.01.09.39.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Aug 2015 09:39:08 -0700 (PDT)
Received: by iggf3 with SMTP id f3so34091421igg.1
        for <linux-mm@kvack.org>; Sat, 01 Aug 2015 09:39:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150801163311.GA15356@nazgul.tnic>
References: <1431714237-880-6-git-send-email-toshi.kani@hp.com>
	<1432628901-18044-6-git-send-email-bp@alien8.de>
	<tip-0cc705f56e400764a171055f727d28a48260bb4b@git.kernel.org>
	<20150731131802.GW25159@twins.programming.kicks-ass.net>
	<20150731144452.GA8106@nazgul.tnic>
	<20150731150806.GX25159@twins.programming.kicks-ass.net>
	<20150731152713.GA9756@nazgul.tnic>
	<20150801142820.GU30479@wotan.suse.de>
	<20150801163311.GA15356@nazgul.tnic>
Date: Sat, 1 Aug 2015 09:39:07 -0700
Message-ID: <CA+55aFzBvRYLufS46QR2aXLYX=rMBQ-qKjkkhQm-L9dFgwWywA@mail.gmail.com>
Subject: Re: [tip:x86/mm] x86/mm/mtrr: Clean up mtrr_type_lookup()
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: "Luis R. Rodriguez" <mcgrof@suse.com>, Toshi Kani <toshi.kani@hp.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Peter Anvin <hpa@zytor.com>, Denys Vlasenko <dvlasenk@redhat.com>, Borislav Petkov <bp@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Brian Gerst <brgerst@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, linux-mm <linux-mm@kvack.org>, Andy Lutomirski <luto@amacapital.net>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-tip-commits@vger.kernel.org" <linux-tip-commits@vger.kernel.org>

On Sat, Aug 1, 2015 at 9:33 AM, Borislav Petkov <bp@alien8.de> wrote:
>
> Well, it doesn't really make sense to write-combine IO memory, does it?

Quite the reverse.

It makes no sense to write-combine normal memory (RAM), because caches
work and sane memory is always cache-coherent. So marking regular
memory write-combining is a sign of crap hardware (which admittedly
exists all too much, but hopefully goes away).

In contrast, marking MMIO memory write-combining is not a sign of crap
hardware - it's just a sign of things like frame buffers on the card
etc. Which very much wants write combining. So WC for MMIO at least
makes sense.

Yes, yes, I realize that "crap hardware" may actually be the more
common case, but still..

             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
