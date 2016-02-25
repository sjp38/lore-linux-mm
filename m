Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id 11A146B0254
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 14:11:54 -0500 (EST)
Received: by mail-qg0-f41.google.com with SMTP id b67so47784263qgb.1
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 11:11:54 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g131si9320857qkb.102.2016.02.25.11.11.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Feb 2016 11:11:53 -0800 (PST)
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
	<x49y4a8iwpy.fsf@segfault.boston.devel.redhat.com>
Date: Thu, 25 Feb 2016 14:11:49 -0500
In-Reply-To: <x49y4a8iwpy.fsf@segfault.boston.devel.redhat.com> (Jeff Moyer's
	message of "Thu, 25 Feb 2016 11:24:57 -0500")
Message-ID: <x49twkwiozu.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Arnd Bergmann <arnd@arndb.de>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Oleg Nesterov <oleg@redhat.com>, Christoph Hellwig <hch@infradead.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Jeff Moyer <jmoyer@redhat.com> writes:

>> The big issue we have right now is that we haven't made the DAX/pmem
>> infrastructure work correctly and reliably for general use.  Hence
>> adding new APIs to workaround cases where we haven't yet provided
>> correct behaviour, let alone optimised for performance is, quite
>> frankly, a clear case premature optimisation.
>
> Again, I see the two things as separate issues.  You need both.
> Implementing MAP_SYNC doesn't mean we don't have to solve the bigger
> issue of making existing applications work safely.

I want to add one more thing to this discussion, just for the sake of
clarity.  When I talk about existing applications and pmem, I mean
applications that already know how to detect and recover from torn
sectors.  Any application that assumes hardware does not tear sectors
should be run on a file system layered on top of the btt.

I think this underlying assumption may have been overlooked in this
discussion, and could very well be a source of confusion.

Cheers,
Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
