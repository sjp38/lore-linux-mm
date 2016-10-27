Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8AF486B027A
	for <linux-mm@kvack.org>; Thu, 27 Oct 2016 17:19:33 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id y138so18218582wme.7
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 14:19:33 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id v126si5686876wmf.37.2016.10.27.14.19.32
        for <linux-mm@kvack.org>;
        Thu, 27 Oct 2016 14:19:32 -0700 (PDT)
Date: Thu, 27 Oct 2016 23:19:30 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: CONFIG_VMAP_STACK, on-stack struct, and wake_up_bit
Message-ID: <20161027211930.2d2wc7tjbe3kfaxk@pd.tnic>
References: <CAHc6FU4e5sueLi7pfeXnSbuuvnc5PaU3xo5Hnn=SvzmQ+ZOEeg@mail.gmail.com>
 <CA+55aFzVmppmua4U0pesp2moz7vVPbH1NP264EKeW3YqOzFc3A@mail.gmail.com>
 <1731570270.13088320.1477515684152.JavaMail.zimbra@redhat.com>
 <20161026231358.36jysz2wycdf4anf@pd.tnic>
 <624629879.13118306.1477528645189.JavaMail.zimbra@redhat.com>
 <20161027123623.j2jri5bandimboff@pd.tnic>
 <411894642.13576957.1477594290544.JavaMail.zimbra@redhat.com>
 <20161027191951.zgcrcmvmla7ayeon@pd.tnic>
 <1932557416.13613945.1477602193309.JavaMail.zimbra@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1932557416.13613945.1477602193309.JavaMail.zimbra@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Peterson <rpeterso@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Andreas Gruenbacher <agruenba@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andy Lutomirski <luto@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Steven Whitehouse <swhiteho@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, linux-mm <linux-mm@kvack.org>

On Thu, Oct 27, 2016 at 05:03:13PM -0400, Bob Peterson wrote:
> I rebooted the machine with and without your patch, about 15 times
> each, and no failures. Not sure why I got it the first time. Must have
> been a one-off.

Ok, thanks for giving it a try!

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
