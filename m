Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f51.google.com (mail-qg0-f51.google.com [209.85.192.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5942A6B009C
	for <linux-mm@kvack.org>; Sat, 28 Feb 2015 17:49:48 -0500 (EST)
Received: by mail-qg0-f51.google.com with SMTP id e89so5714130qgf.10
        for <linux-mm@kvack.org>; Sat, 28 Feb 2015 14:49:48 -0800 (PST)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id w8si8040891qat.15.2015.02.28.14.49.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 28 Feb 2015 14:49:47 -0800 (PST)
Message-ID: <1425163779.4645.151.camel@kernel.crashing.org>
Subject: Re: Generic page fault (Was: libsigsegv ....)
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Sun, 01 Mar 2015 09:49:39 +1100
In-Reply-To: <CA+55aFzLQWZJR+Y8HAhdPDSiL0QH_Lx2BqPkiFckAO69bJcOtA@mail.gmail.com>
References: <1422361485.6648.71.camel@opensuse.org>
	 <54C78756.9090605@suse.cz>
	 <alpine.LSU.2.11.1501271347440.30227@nerf60.vanv.qr>
	 <1422364084.6648.82.camel@opensuse.org> <s5h7fw8hvdp.wl-tiwai@suse.de>
	 <CA+55aFyzy_wYHHnr2gDcYr7qcgOKM2557bRdg6RBa=cxrynd+Q@mail.gmail.com>
	 <CA+55aFxRnj97rpSQvvzLJhpo7C8TQ-F=eB1Ry2n53AV1rN8mwA@mail.gmail.com>
	 <CAMo8BfLsKCV_2NfgMH4k9jGOHs_-3=NKjCD3o3KK1uH23-6RRg@mail.gmail.com>
	 <CA+55aFzQ5QEZ1AYauWviq1gp5j=mqByAtt4fpteeK7amuxcyjw@mail.gmail.com>
	 <1422836637.17302.9.camel@au1.ibm.com>
	 <CA+55aFw9sg7pu9-2RbMGyPv5yUtcH54QowoH+5RhWqpPYg4YGQ@mail.gmail.com>
	 <1425107567.4645.108.camel@kernel.crashing.org>
	 <CA+55aFy5UvzSgOMKq09u4psz5twtC4aowuK6tofGKDEu-KFMJQ@mail.gmail.com>
	 <1425158083.4645.139.camel@kernel.crashing.org>
	 <CA+55aFzLQWZJR+Y8HAhdPDSiL0QH_Lx2BqPkiFckAO69bJcOtA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Sat, 2015-02-28 at 13:49 -0800, Linus Torvalds wrote:

 .../...

>  - we handle write faults separately (see the first part of access_error()
> 
>  - so now we know it was a read or an instruction fetch
> 
>  - if PF_PROT is set, that means that the present bit was set in the
> page tables, so it must have been an exec access to a NX page
> 
>  - otherwise, we just say "PROTNONE means no access, otherwise
> populate the page tables"
> 
> .. and if it turns out that it was a PF_INSTR to a NX page, we'll end
> up taking the page fault *again* after it's been populated, and now
> since the page table was populated, the access_error() will catch it
> with the PF_PROT case.
> 
> Or something like that. I might have screwed up some detail, but it
> should all work.

I see, it should work yes, I'll still add that FAULT_FLAG_EXEC for
those who can tell reliably but it shouldn't hurt for x86 to not set it.

Cheers,
Ben.


>                      Linus
> --
> To unsubscribe from this list: send the line "unsubscribe linux-arch" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
