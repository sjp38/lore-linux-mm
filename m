Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5E2666B027A
	for <linux-mm@kvack.org>; Thu, 27 Oct 2016 17:04:09 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id m83so18069619wmc.1
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 14:04:09 -0700 (PDT)
Received: from mx6-phx2.redhat.com (mx6-phx2.redhat.com. [209.132.183.39])
        by mx.google.com with ESMTPS id cw8si10888623wjb.50.2016.10.27.14.04.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Oct 2016 14:04:08 -0700 (PDT)
Date: Thu, 27 Oct 2016 17:03:13 -0400 (EDT)
From: Bob Peterson <rpeterso@redhat.com>
Message-ID: <1932557416.13613945.1477602193309.JavaMail.zimbra@redhat.com>
In-Reply-To: <20161027191951.zgcrcmvmla7ayeon@pd.tnic>
References: <CAHc6FU4e5sueLi7pfeXnSbuuvnc5PaU3xo5Hnn=SvzmQ+ZOEeg@mail.gmail.com> <CA+55aFzVmppmua4U0pesp2moz7vVPbH1NP264EKeW3YqOzFc3A@mail.gmail.com> <1731570270.13088320.1477515684152.JavaMail.zimbra@redhat.com> <20161026231358.36jysz2wycdf4anf@pd.tnic> <624629879.13118306.1477528645189.JavaMail.zimbra@redhat.com> <20161027123623.j2jri5bandimboff@pd.tnic> <411894642.13576957.1477594290544.JavaMail.zimbra@redhat.com> <20161027191951.zgcrcmvmla7ayeon@pd.tnic>
Subject: Re: CONFIG_VMAP_STACK, on-stack struct, and wake_up_bit
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Andreas Gruenbacher <agruenba@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andy Lutomirski <luto@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Steven Whitehouse <swhiteho@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, linux-mm <linux-mm@kvack.org>

----- Original Message -----
| I mean, it would be great if you try a couple times but even if you're
| unsuccessful, that's fine too - the fix is obviously correct and I've
| confirmed that it boots fine in my VM here.

Hi Boris,

I rebooted the machine with and without your patch, about 15 times each,
and no failures. Not sure why I got it the first time. Must have been a one-off.

Bob Peterson

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
