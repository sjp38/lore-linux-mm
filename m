Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id E57756B0006
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 11:08:33 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id y13-v6so5964012ita.8
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 08:08:33 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g82-v6sor2312535ioe.6.2018.07.19.08.08.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 19 Jul 2018 08:08:32 -0700 (PDT)
MIME-Version: 1.0
References: <20180712172942.10094-1-hannes@cmpxchg.org> <20180712172942.10094-9-hannes@cmpxchg.org>
 <20180718120318.GC2476@hirez.programming.kicks-ass.net>
In-Reply-To: <20180718120318.GC2476@hirez.programming.kicks-ass.net>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 19 Jul 2018 08:08:20 -0700
Message-ID: <CA+55aFw7t++BzEy-XsatNcauw3Wn22SSXfd3iTYECi4fJ97CCg@mail.gmail.com>
Subject: Re: [PATCH 08/10] psi: pressure stall information for CPU, memory,
 and IO
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, surenb@google.com, Vinayak Menon <vinmenon@codeaurora.org>, Christoph Lameter <cl@linux.com>, Mike Galbraith <efault@gmx.de>, shakeelb@google.com, linux-mm <linux-mm@kvack.org>, cgroups <cgroups@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, kernel-team <kernel-team@fb.com>

On Wed, Jul 18, 2018 at 5:03 AM Peter Zijlstra <peterz@infradead.org> wrote:
>
> And as said before, we can compress the state from 12 bytes, to 6 bits
> (or 1 byte), giving another 11 bytes for 59 bytes free.
>
> Leaving us just 5 bytes short of needing a single cacheline :/

Do you actually need 64 bits for the times?

That's the big cost. And it seems ridiculous, if you actually care about size.

You already have a 64-bit start time. Everything else is some
cumulative relative time. Do those really need 64-bit and nanosecond
resolution?

Maybe a 32-bit microsecond would be ok - would you ever account more
than 35 minutes of anything without starting anew?

             Linus
