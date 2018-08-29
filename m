Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 53F836B4E3E
	for <linux-mm@kvack.org>; Wed, 29 Aug 2018 19:15:50 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id l6-v6so5979864iog.4
        for <linux-mm@kvack.org>; Wed, 29 Aug 2018 16:15:50 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v128-v6sor47196ith.25.2018.08.29.16.15.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 Aug 2018 16:15:49 -0700 (PDT)
MIME-Version: 1.0
References: <20180828112034.30875-1-npiggin@gmail.com> <20180828112034.30875-3-npiggin@gmail.com>
 <CA+55aFwbZrsdZEh0ds1W3AWUeTamDRheQPKSi9O=--cEOSjr5g@mail.gmail.com> <20180830091213.78b64354@roar.ozlabs.ibm.com>
In-Reply-To: <20180830091213.78b64354@roar.ozlabs.ibm.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 29 Aug 2018 16:15:37 -0700
Message-ID: <CA+55aFzBHNsLNs4TfOrMQXTsV9u8=7yAu4GbsOM84AQb-OhJmg@mail.gmail.com>
Subject: Re: [PATCH 2/3] mm/cow: optimise pte dirty/accessed bits handling in fork
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nick Piggin <npiggin@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, ppc-dev <linuxppc-dev@lists.ozlabs.org>, Andrew Morton <akpm@linux-foundation.org>

On Wed, Aug 29, 2018 at 4:12 PM Nicholas Piggin <npiggin@gmail.com> wrote:
>
> Dirty micro fault seems to be the big one for my Skylake, takes 300
> nanoseconds per access. Accessed takes about 100. (I think, have to
> go over my benchmark a bit more carefully and re-test).

Yeah, but they only happen for shared areas after fork, which sounds
like it shouldn't be a big deal in most cases.

And I'm not entirely objecting to your patch per se, I just would want
to keep the accessed bit changes separate from the dirty bit ones.

*If* somebody has bisectable issues with it (performance or not), it
will then be clearer what the exact issue is.

            Linus
