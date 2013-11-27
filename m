Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f178.google.com (mail-ie0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id 5C29E6B0035
	for <linux-mm@kvack.org>; Wed, 27 Nov 2013 18:58:00 -0500 (EST)
Received: by mail-ie0-f178.google.com with SMTP id lx4so13525835iec.9
        for <linux-mm@kvack.org>; Wed, 27 Nov 2013 15:58:00 -0800 (PST)
Received: from relay.sgi.com (relay2.sgi.com. [192.48.179.30])
        by mx.google.com with ESMTP id fi5si9567765icc.146.2013.11.27.15.57.57
        for <linux-mm@kvack.org>;
        Wed, 27 Nov 2013 15:57:58 -0800 (PST)
Date: Wed, 27 Nov 2013 17:58:16 -0600
From: Alex Thorlton <athorlton@sgi.com>
Subject: Re: BUG: mm, numa: test segfaults, only when NUMA balancing is on
Message-ID: <20131127235816.GG22514@sgi.com>
References: <20131106131048.GC4877@suse.de>
 <20131107214838.GY3066@sgi.com>
 <20131108112054.GB5040@suse.de>
 <20131108221329.GD4236@sgi.com>
 <20131112212902.GA4725@sgi.com>
 <20131115000901.GB26002@suse.de>
 <20131115144504.GE26002@suse.de>
 <20131122212807.GR3062@sgi.com>
 <20131122230524.GB5285@suse.de>
 <20131123000924.GC5285@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131123000924.GC5285@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, Nov 23, 2013 at 12:09:24AM +0000, Mel Gorman wrote:
> On Fri, Nov 22, 2013 at 11:05:24PM +0000, Mel Gorman wrote:
> > On Fri, Nov 22, 2013 at 03:28:07PM -0600, Alex Thorlton wrote:
> > > > If the warning added by that patch does *not* trigger than can you also
> > > > test this patch? It removes the barriers which should not be necessary
> > > > and takes a reference tot he page before waiting on the lock. The
> > > > previous version did not take the reference because otherwise the
> > > > WARN_ON could not distinguish between a migration waiter and a surprise
> > > > gup.
> > > 
> > > Sorry for the delay; been a bit busy.  I tested both of these patches on
> > > top of this one (separately, of course):
> > > 
> > > http://www.spinics.net/lists/linux-mm/msg63919.html
> > > 
> > > I think that's the one you were referring to, if not send me a pointer
> > > to the correct one and I'll give it another shot.  Both patches still
> > > segfaulted, so it doesn't appear that either of these solved the
> > > problem. 
> > 
> > I see. Does THP have to be enabled or does it segfault even with THP
> > disabled?

It occurs with both THP on, and off.  I get RCU stalls with THP on
though.  That's probably related to not having Kirill/Naoya's patches
applied though.

> > 
> 
> On a semi-related note, is the large machine doing anything with xpmem
> or anything that depends on MMU notifiers to work properly? I noted
> while looking at this that THP migration is not invalidating pages which
> might be confusing a driver depending on it.

I'm not using xpmem on any of the machines that I've been testing on,
and I don't think that anything should be using MMU notifiers.

- Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
