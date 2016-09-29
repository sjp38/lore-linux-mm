Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4D0B46B0253
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 09:55:01 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id cg13so142106239pac.1
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 06:55:01 -0700 (PDT)
Received: from mail-pf0-x22d.google.com (mail-pf0-x22d.google.com. [2607:f8b0:400e:c00::22d])
        by mx.google.com with ESMTPS id p72si14489322pfi.197.2016.09.29.06.55.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Sep 2016 06:55:00 -0700 (PDT)
Received: by mail-pf0-x22d.google.com with SMTP id q2so29361491pfj.3
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 06:55:00 -0700 (PDT)
Date: Thu, 29 Sep 2016 23:54:48 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: page_waitqueue() considered harmful
Message-ID: <20160929235448.62197e3e@roar.ozlabs.ibm.com>
In-Reply-To: <20160929131635.GY5016@twins.programming.kicks-ass.net>
References: <CA+55aFwVSXZPONk2OEyxcP-aAQU7-aJsF3OFXVi8Z5vA11v_-Q@mail.gmail.com>
	<20160927073055.GM2794@worktop>
	<20160927085412.GD2838@techsingularity.net>
	<20160929080130.GJ3318@worktop.controleur.wifipass.org>
	<20160929225544.70a23dac@roar.ozlabs.ibm.com>
	<20160929131635.GY5016@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>

On Thu, 29 Sep 2016 15:16:35 +0200
Peter Zijlstra <peterz@infradead.org> wrote:

> On Thu, Sep 29, 2016 at 10:55:44PM +1000, Nicholas Piggin wrote:
> > On Thu, 29 Sep 2016 10:01:30 +0200
> > Peter Zijlstra <peterz@infradead.org> wrote:
> >   
> > > On Tue, Sep 27, 2016 at 09:54:12AM +0100, Mel Gorman wrote:  
> > > > On Tue, Sep 27, 2016 at 09:30:55AM +0200, Peter Zijlstra wrote:
> > > > Simple is relative unless I drastically overcomplicated things and it
> > > > wouldn't be the first time. 64-bit only side-steps the page flag issue
> > > > as long as we can live with that.    
> > > 
> > > So one problem with the 64bit only pageflags is that they do eat space
> > > from page-flags-layout, we do try and fit a bunch of other crap in
> > > there, and at some point that all will not fit anymore and we'll revert
> > > to worse.
> > > 
> > > I've no idea how far away from that we are for distro kernels. I suppose
> > > they have fairly large NR_NODES and NR_CPUS.  
> > 
> > I know it's not fashionable to care about them anymore, but it's sad if
> > 32-bit architectures miss out fundamental optimisations like this because
> > we're out of page flags. It would also be sad to increase the size of
> > struct page because we're too lazy to reduce flags. There's some that
> > might be able to be removed.  
> 
> I'm all for cleaning some of that up, but its been a long while since I
> poked in that general area.

Forgive my rant! Cleaning page flags is a topic of its own...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
