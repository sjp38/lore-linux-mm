Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id 0BB3F6B0254
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 11:25:02 -0500 (EST)
Received: by mail-qg0-f46.google.com with SMTP id y9so44264766qgd.3
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 08:25:02 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f17si8676143qhc.19.2016.02.25.08.25.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Feb 2016 08:25:01 -0800 (PST)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [RFC 0/2] New MAP_PMEM_AWARE mmap flag
References: <20160223095225.GB32294@infradead.org>
	<56CC686A.9040909@plexistor.com>
	<CAPcyv4gTaikkXCG1fPBVT-0DE8Wst3icriUH5cbQH3thuEe-ow@mail.gmail.com>
	<56CCD54C.3010600@plexistor.com>
	<CAPcyv4iqO=Pzu_r8tV6K2G953c5HqJRdqCE1pymfDmURy8_ODw@mail.gmail.com>
	<x49egc3c8gf.fsf@segfault.boston.devel.redhat.com>
	<CAPcyv4jUkMikW_x1EOTHXH4GC5DkPieL=sGd0-ajZqmG6C7DEg@mail.gmail.com>
	<x49a8mrc7rn.fsf@segfault.boston.devel.redhat.com>
	<CAPcyv4hMJ_+o2hYU7xnKEWUcKpcPVd66e2KChwL96Qxxk2R8iQ@mail.gmail.com>
	<x49a8mqgni5.fsf@segfault.boston.devel.redhat.com>
	<20160224225623.GL14668@dastard>
Date: Thu, 25 Feb 2016 11:24:57 -0500
In-Reply-To: <20160224225623.GL14668@dastard> (Dave Chinner's message of "Thu,
	25 Feb 2016 09:56:23 +1100")
Message-ID: <x49y4a8iwpy.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Boaz Harrosh <boaz@plexistor.com>, Christoph Hellwig <hch@infradead.org>, "Rudoff, Andy" <andy.rudoff@intel.com>, Arnd Bergmann <arnd@arndb.de>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Hi, Dave,

Dave Chinner <david@fromorbit.com> writes:

> Well, let me clarify what I said a bit here, because I feel like I'm
> being unfairly blamed for putting data integrity as the highest
> priority for DAX+pmem instead of falling in line and chanting
> "Performance! Performance! Performance!" with everyone else.

It's totally fair.  ;-)

> Let me state this clearly: I'm not opposed to making optimisations
> that change the way applications and the kernel interact. I like the
> idea of MAP_SYNC, but I see this sort of API/behaviour change as a
> last resort when all else fails, not a "first and only" optimisation
> option.

So, calling it "first and only" seems a bit unfair on your part.  I
don't think anyone asking for a MAP_SYNC option doesn't also want other
applications to work well.  That aside, this is where your opinion
differs from mine: I don't see MAP_SYNC as a last resort option.  And
let me be clear, this /is/ an opinion.  I have no hard facts to back it
up, precisely because we don't have any application we can use for a
comparison.  But, it seems plausible to me that no matter how well you
optimize your msync implementation, it will still be more expensive than
an application that doesn't call msync at all.  This obviously depends
on how the application is using the programming model, among other
things.  I agree that we would need real data to back this up.  However,
I don't see any reason to preclude such an implementation, or to leave
it as a last resort.  I think it should be part of our planning process
if it's reasonably feasible.

> The big issue we have right now is that we haven't made the DAX/pmem
> infrastructure work correctly and reliably for general use.  Hence
> adding new APIs to workaround cases where we haven't yet provided
> correct behaviour, let alone optimised for performance is, quite
> frankly, a clear case premature optimisation.

Again, I see the two things as separate issues.  You need both.
Implementing MAP_SYNC doesn't mean we don't have to solve the bigger
issue of making existing applications work safely.

Cheers,
Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
