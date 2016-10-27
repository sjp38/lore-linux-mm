Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id C298D6B027A
	for <linux-mm@kvack.org>; Thu, 27 Oct 2016 15:19:54 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b80so16416387wme.5
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 12:19:54 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id g125si4954309wma.144.2016.10.27.12.19.53
        for <linux-mm@kvack.org>;
        Thu, 27 Oct 2016 12:19:53 -0700 (PDT)
Date: Thu, 27 Oct 2016 21:19:51 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: CONFIG_VMAP_STACK, on-stack struct, and wake_up_bit
Message-ID: <20161027191951.zgcrcmvmla7ayeon@pd.tnic>
References: <CAHc6FU4e5sueLi7pfeXnSbuuvnc5PaU3xo5Hnn=SvzmQ+ZOEeg@mail.gmail.com>
 <CA+55aFyRv0YttbLUYwDem=-L5ZAET026umh6LOUQ6hWaRur_VA@mail.gmail.com>
 <996124132.13035408.1477505043741.JavaMail.zimbra@redhat.com>
 <CA+55aFzVmppmua4U0pesp2moz7vVPbH1NP264EKeW3YqOzFc3A@mail.gmail.com>
 <1731570270.13088320.1477515684152.JavaMail.zimbra@redhat.com>
 <20161026231358.36jysz2wycdf4anf@pd.tnic>
 <624629879.13118306.1477528645189.JavaMail.zimbra@redhat.com>
 <20161027123623.j2jri5bandimboff@pd.tnic>
 <411894642.13576957.1477594290544.JavaMail.zimbra@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <411894642.13576957.1477594290544.JavaMail.zimbra@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Peterson <rpeterso@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Andreas Gruenbacher <agruenba@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andy Lutomirski <luto@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Steven Whitehouse <swhiteho@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, linux-mm <linux-mm@kvack.org>

On Thu, Oct 27, 2016 at 02:51:30PM -0400, Bob Peterson wrote:
> I couldn't recreate that first boot failure, even using .config.old,
> and even after removing (rm -fR) my linux.git and untarring it from the
> original tarball, doing a make clean, etc.

Hmm, so it could also depend on the randomized offset as it is getting
generated anew each boot. So you could try to boot a couple of times
to see if the randomized offset is generated just right for the bug
condition to match.

I mean, it would be great if you try a couple times but even if you're
unsuccessful, that's fine too - the fix is obviously correct and I've
confirmed that it boots fine in my VM here.

> The output before and after your new patch are the same (except for the times):
> 
> # dmesg | grep -i microcode
> [    5.291679] microcode: microcode updated early to new patch_level=0x010000d9

That looks good.

Thanks!

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
