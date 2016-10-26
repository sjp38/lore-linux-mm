Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id AE3F76B0275
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 18:09:42 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id n202so18996811oig.3
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 15:09:42 -0700 (PDT)
Received: from mail-oi0-x22a.google.com (mail-oi0-x22a.google.com. [2607:f8b0:4003:c06::22a])
        by mx.google.com with ESMTPS id f27si2785922otd.81.2016.10.26.15.09.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Oct 2016 15:09:42 -0700 (PDT)
Received: by mail-oi0-x22a.google.com with SMTP id y2so14790549oie.0
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 15:09:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20161026220339.GE2699@techsingularity.net>
References: <CAHc6FU4e5sueLi7pfeXnSbuuvnc5PaU3xo5Hnn=SvzmQ+ZOEeg@mail.gmail.com>
 <CALCETrUt+4ojyscJT1AFN5Zt3mKY0rrxcXMBOUUJzzLMWXFXHg@mail.gmail.com>
 <CA+55aFzB2C0aktFZW3GquJF6dhM1904aDPrv4vdQ8=+mWO7jcg@mail.gmail.com>
 <CA+55aFww1iLuuhHw=iYF8xjfjGj8L+3oh33xxUHjnKKnsR-oHg@mail.gmail.com>
 <20161026203158.GD2699@techsingularity.net> <CA+55aFy21NqcYTeLVVz4x4kfQ7A+o4HEv7srone6ppKAjCwn7g@mail.gmail.com>
 <20161026220339.GE2699@techsingularity.net>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 26 Oct 2016 15:09:41 -0700
Message-ID: <CA+55aFwgZ6rUL2-KD7A38xEkALJcvk8foT2TBjLrvy8caj7k9w@mail.gmail.com>
Subject: Re: CONFIG_VMAP_STACK, on-stack struct, and wake_up_bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andy Lutomirski <luto@amacapital.net>, Andreas Gruenbacher <agruenba@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andy Lutomirski <luto@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Bob Peterson <rpeterso@redhat.com>, Steven Whitehouse <swhiteho@redhat.com>, linux-mm <linux-mm@kvack.org>

On Wed, Oct 26, 2016 at 3:03 PM, Mel Gorman <mgorman@techsingularity.net> wrote:
>
> To be clear, are you referring to PeterZ's patch that avoids the lookup? If
> so, I see your point.

Yup, that's the one. I think you tested it. In fact, I'm sure you did,
because I remember seeing performance numbers from  you ;)

So yes, I'd expect my patch on its own to quite possibly regress on
NUMA systems (although I wonder how much), but I consider PeterZ's
patch the fix to that, so I wouldn't worry about it.

              Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
