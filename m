Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id B9CBB6B0275
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 19:14:02 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 2so19824174wmj.0
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 16:14:02 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id 15si9594996wml.101.2016.10.26.16.14.01
        for <linux-mm@kvack.org>;
        Wed, 26 Oct 2016 16:14:01 -0700 (PDT)
Date: Thu, 27 Oct 2016 01:13:58 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: CONFIG_VMAP_STACK, on-stack struct, and wake_up_bit
Message-ID: <20161026231358.36jysz2wycdf4anf@pd.tnic>
References: <CAHc6FU4e5sueLi7pfeXnSbuuvnc5PaU3xo5Hnn=SvzmQ+ZOEeg@mail.gmail.com>
 <CALCETrUt+4ojyscJT1AFN5Zt3mKY0rrxcXMBOUUJzzLMWXFXHg@mail.gmail.com>
 <CA+55aFzB2C0aktFZW3GquJF6dhM1904aDPrv4vdQ8=+mWO7jcg@mail.gmail.com>
 <CA+55aFww1iLuuhHw=iYF8xjfjGj8L+3oh33xxUHjnKKnsR-oHg@mail.gmail.com>
 <CA+55aFyRv0YttbLUYwDem=-L5ZAET026umh6LOUQ6hWaRur_VA@mail.gmail.com>
 <996124132.13035408.1477505043741.JavaMail.zimbra@redhat.com>
 <CA+55aFzVmppmua4U0pesp2moz7vVPbH1NP264EKeW3YqOzFc3A@mail.gmail.com>
 <1731570270.13088320.1477515684152.JavaMail.zimbra@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1731570270.13088320.1477515684152.JavaMail.zimbra@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Peterson <rpeterso@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Andreas Gruenbacher <agruenba@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andy Lutomirski <luto@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Steven Whitehouse <swhiteho@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, linux-mm <linux-mm@kvack.org>

On Wed, Oct 26, 2016 at 05:01:24PM -0400, Bob Peterson wrote:
> Hm. It didn't even boot, at least on my amd box in the lab.
> I've made no attempt to debug this.

Btw, can you send me your .config so that I can try to reproduce?

I'm assuming you're booting latest Linus' tree on it?

I'd need to take care of this for 4.9.

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
