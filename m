Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 560EA6B0031
	for <linux-mm@kvack.org>; Tue,  1 Apr 2014 15:26:26 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id kx10so4778656pab.5
        for <linux-mm@kvack.org>; Tue, 01 Apr 2014 12:26:25 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id bo2si11794120pbb.250.2014.04.01.12.26.24
        for <linux-mm@kvack.org>;
        Tue, 01 Apr 2014 12:26:25 -0700 (PDT)
Date: Tue, 1 Apr 2014 12:26:23 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] ipc,shm: increase default size for shmmax
Message-Id: <20140401122623.30f9d4e8106031f714e01ebb@linux-foundation.org>
In-Reply-To: <1396371699.25314.11.camel@buesod1.americas.hpqcorp.net>
References: <1396235199.2507.2.camel@buesod1.americas.hpqcorp.net>
	<20140331143217.c6ff958e1fd9944d78507418@linux-foundation.org>
	<1396306773.18499.22.camel@buesod1.americas.hpqcorp.net>
	<20140331161308.6510381345cb9a1b419d5ec0@linux-foundation.org>
	<1396308332.18499.25.camel@buesod1.americas.hpqcorp.net>
	<20140331170546.3b3e72f0.akpm@linux-foundation.org>
	<1396371699.25314.11.camel@buesod1.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Manfred Spraul <manfred@colorfullife.com>, aswin@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 01 Apr 2014 10:01:39 -0700 Davidlohr Bueso <davidlohr@hp.com> wrote:

> > > EINVAL A new segment was to be created and size < SHMMIN or size >
> > > SHMMAX, or no new segment was to be created, a segment with given key
> > > existed, but size is greater than the size of that segment.
> > 
> > So their system will act as if they had set SHMMAX=enormous.  What
> > problems could that cause?
> 
> So, just like any sysctl configurable, only privileged users can change
> this value. If we remove this option, users can theoretically create
> huge segments, thus ignoring any custom limit previously set. This is
> what I fear.

What's wrong with that?  Waht are we actually ptoecting the system
from?  tmpfs exhaustion?

> Think of it kind of like mlock's rlimit. And for that
> matter, why does sysctl exist at all, the same would go for the rest of
> the limits.

These things exist to protect the system from intentional or accidental
service denials.  What are the service denials in this case?

> > Look.  The 32M thing is causing problems.  Arbitrarily increasing the
> > arbitrary 32M to an arbitrary 128M won't fix anything - we still have
> > the problem.  Think bigger, please: how can we make this problem go
> > away for ever?
> 
> That's the thing, I don't think we can make it go away without breaking
> userspace.

Still waiting for details!

> I'm not saying that my 4x increase is the correct value, I
> don't think any default value is really correct, as with any other
> hardcoded limits there are pros and cons. That's really why we give
> users the option to change it to the "correct" one via sysctl. All I'm
> saying is that 32mb is just too small for default in today's systems,
> and increasing it is just making a bad situation a tiny bit better.

Let's understand what's preventing us from making it a great deal better.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
