Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 6BA8A6B0038
	for <linux-mm@kvack.org>; Sat,  1 Aug 2015 12:49:13 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so66373466wib.1
        for <linux-mm@kvack.org>; Sat, 01 Aug 2015 09:49:13 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id et10si4288930wib.62.2015.08.01.09.49.11
        for <linux-mm@kvack.org>;
        Sat, 01 Aug 2015 09:49:12 -0700 (PDT)
Date: Sat, 1 Aug 2015 18:49:10 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [tip:x86/mm] x86/mm/mtrr: Clean up mtrr_type_lookup()
Message-ID: <20150801164910.GA15407@nazgul.tnic>
References: <1431714237-880-6-git-send-email-toshi.kani@hp.com>
 <1432628901-18044-6-git-send-email-bp@alien8.de>
 <tip-0cc705f56e400764a171055f727d28a48260bb4b@git.kernel.org>
 <20150731131802.GW25159@twins.programming.kicks-ass.net>
 <20150731144452.GA8106@nazgul.tnic>
 <20150731150806.GX25159@twins.programming.kicks-ass.net>
 <20150731152713.GA9756@nazgul.tnic>
 <20150801142820.GU30479@wotan.suse.de>
 <20150801163311.GA15356@nazgul.tnic>
 <CA+55aFzBvRYLufS46QR2aXLYX=rMBQ-qKjkkhQm-L9dFgwWywA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CA+55aFzBvRYLufS46QR2aXLYX=rMBQ-qKjkkhQm-L9dFgwWywA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Luis R. Rodriguez" <mcgrof@suse.com>, Toshi Kani <toshi.kani@hp.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Peter Anvin <hpa@zytor.com>, Denys Vlasenko <dvlasenk@redhat.com>, Borislav Petkov <bp@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Brian Gerst <brgerst@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, linux-mm <linux-mm@kvack.org>, Andy Lutomirski <luto@amacapital.net>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-tip-commits@vger.kernel.org" <linux-tip-commits@vger.kernel.org>

On Sat, Aug 01, 2015 at 09:39:07AM -0700, Linus Torvalds wrote:
> Quite the reverse.
> 
> It makes no sense to write-combine normal memory (RAM), because caches
> work and sane memory is always cache-coherent. So marking regular
> memory write-combining is a sign of crap hardware (which admittedly
> exists all too much, but hopefully goes away).
> 
> In contrast, marking MMIO memory write-combining is not a sign of crap
> hardware - it's just a sign of things like frame buffers on the card
> etc. Which very much wants write combining. So WC for MMIO at least
> makes sense.
> 
> Yes, yes, I realize that "crap hardware" may actually be the more
> common case, but still..

Hmm, ok.

My simplistic mental picture while thinking of this is the IO range
where you send the commands to the device and you don't really want to
delay those but they should reach the device as they get issued.

OTOH, your example with frame buffers really wants to WC because sending
down each write separately is plain dumb.

Ok, I see, so it can make sense to have WC IO memory, depending on the
range and what you're going to use it for, I guess...

Thanks.

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
