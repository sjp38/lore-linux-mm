Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id D54796B0278
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 14:10:54 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id p136so4510487oic.2
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 11:10:54 -0700 (PDT)
Received: from mail-oi0-x233.google.com (mail-oi0-x233.google.com. [2607:f8b0:4003:c06::233])
        by mx.google.com with ESMTPS id p133si2495737oih.262.2016.10.26.11.10.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Oct 2016 11:10:54 -0700 (PDT)
Received: by mail-oi0-x233.google.com with SMTP id y2so3718531oie.0
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 11:10:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <996124132.13035408.1477505043741.JavaMail.zimbra@redhat.com>
References: <CAHc6FU4e5sueLi7pfeXnSbuuvnc5PaU3xo5Hnn=SvzmQ+ZOEeg@mail.gmail.com>
 <CALCETrUt+4ojyscJT1AFN5Zt3mKY0rrxcXMBOUUJzzLMWXFXHg@mail.gmail.com>
 <CA+55aFzB2C0aktFZW3GquJF6dhM1904aDPrv4vdQ8=+mWO7jcg@mail.gmail.com>
 <CA+55aFww1iLuuhHw=iYF8xjfjGj8L+3oh33xxUHjnKKnsR-oHg@mail.gmail.com>
 <CA+55aFyRv0YttbLUYwDem=-L5ZAET026umh6LOUQ6hWaRur_VA@mail.gmail.com> <996124132.13035408.1477505043741.JavaMail.zimbra@redhat.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 26 Oct 2016 11:10:53 -0700
Message-ID: <CA+55aFzVmppmua4U0pesp2moz7vVPbH1NP264EKeW3YqOzFc3A@mail.gmail.com>
Subject: Re: CONFIG_VMAP_STACK, on-stack struct, and wake_up_bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Peterson <rpeterso@redhat.com>
Cc: Andy Lutomirski <luto@amacapital.net>, Andreas Gruenbacher <agruenba@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andy Lutomirski <luto@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Steven Whitehouse <swhiteho@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, linux-mm <linux-mm@kvack.org>

On Wed, Oct 26, 2016 at 11:04 AM, Bob Peterson <rpeterso@redhat.com> wrote:
>
> I can test it for you, if you give me about an hour.

I can definitely wait an hour, it would be lovely to see more testing.
Especially if you have a NUMA machine and an interesting workload.

And if you actually have that NUMA machine and a load that shows the
page_waietutu effects, it would also be lovely if you can then
_additionally_ test the patch that PeterZ wrote a few weeks ago, it
was on the mm list about a month ago:

  Date: Thu, 29 Sep 2016 15:08:27 +0200
  From: Peter Zijlstra <peterz@infradead.org>
  Subject: Re: page_waitqueue() considered harmful
  Message-ID: <20160929130827.GX5016@twins.programming.kicks-ass.net>

and if you don't find it I can forward it to you (Peter had a few
versions, that latest one is the one that looked best).

                Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
