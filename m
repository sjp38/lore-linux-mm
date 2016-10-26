Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0615C6B0278
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 14:04:36 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id l124so6705550wml.4
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 11:04:35 -0700 (PDT)
Received: from mx5-phx2.redhat.com (mx5-phx2.redhat.com. [209.132.183.37])
        by mx.google.com with ESMTPS id b10si11979081wmg.7.2016.10.26.11.04.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Oct 2016 11:04:34 -0700 (PDT)
Date: Wed, 26 Oct 2016 14:04:03 -0400 (EDT)
From: Bob Peterson <rpeterso@redhat.com>
Message-ID: <996124132.13035408.1477505043741.JavaMail.zimbra@redhat.com>
In-Reply-To: <CA+55aFyRv0YttbLUYwDem=-L5ZAET026umh6LOUQ6hWaRur_VA@mail.gmail.com>
References: <CAHc6FU4e5sueLi7pfeXnSbuuvnc5PaU3xo5Hnn=SvzmQ+ZOEeg@mail.gmail.com> <CALCETrUt+4ojyscJT1AFN5Zt3mKY0rrxcXMBOUUJzzLMWXFXHg@mail.gmail.com> <CA+55aFzB2C0aktFZW3GquJF6dhM1904aDPrv4vdQ8=+mWO7jcg@mail.gmail.com> <CA+55aFww1iLuuhHw=iYF8xjfjGj8L+3oh33xxUHjnKKnsR-oHg@mail.gmail.com> <CA+55aFyRv0YttbLUYwDem=-L5ZAET026umh6LOUQ6hWaRur_VA@mail.gmail.com>
Subject: Re: CONFIG_VMAP_STACK, on-stack struct, and wake_up_bit
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andy Lutomirski <luto@amacapital.net>, Andreas Gruenbacher <agruenba@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andy Lutomirski <luto@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Steven Whitehouse <swhiteho@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, linux-mm <linux-mm@kvack.org>

----- Original Message -----
| On Wed, Oct 26, 2016 at 10:15 AM, Linus Torvalds
| <torvalds@linux-foundation.org> wrote:
| >
| > Oh, and the patch is obviously entirely untested. I wouldn't want to
| > ruin my reputation by *testing* the patches I send out. What would be
| > the fun in that?
| 
| So I tested it. It compiles, and it actually also solves the
| performance problem I was complaining about a couple of weeks ago with
| "unlock_page()" having an insane 3% CPU overhead when doing lots of
| small script ("make -j16 test" in the git tree for those that weren't
| involved in the original thread three weeks ago).
| 
| So quite frankly, I'll just commit it. It should fix the new problem
| with gfs2 and CONFIG_VMAP_STACK, and I see no excuse for the crazy
| zone stuff considering how harmful it is to everybody else.
| 
| I expect that when the NUMA people complain about page locking (if
| they ever even notice), PeterZ will stand up like the hero he is, and
| say "look here, I can solve this for you".
| 
|                     Linus
| 
I can test it for you, if you give me about an hour.

Bob Peterson

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
