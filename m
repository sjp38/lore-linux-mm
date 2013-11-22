Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f179.google.com (mail-ie0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id CCC1F6B0036
	for <linux-mm@kvack.org>; Fri, 22 Nov 2013 16:28:02 -0500 (EST)
Received: by mail-ie0-f179.google.com with SMTP id x13so2996789ief.24
        for <linux-mm@kvack.org>; Fri, 22 Nov 2013 13:28:02 -0800 (PST)
Received: from relay.sgi.com (relay2.sgi.com. [192.48.179.30])
        by mx.google.com with ESMTP id jv7si18166907icc.23.2013.11.22.13.28.01
        for <linux-mm@kvack.org>;
        Fri, 22 Nov 2013 13:28:01 -0800 (PST)
Date: Fri, 22 Nov 2013 15:28:07 -0600
From: Alex Thorlton <athorlton@sgi.com>
Subject: Re: BUG: mm, numa: test segfaults, only when NUMA balancing is on
Message-ID: <20131122212807.GR3062@sgi.com>
References: <20131016155429.GP25735@sgi.com>
 <20131104145828.GA1218@suse.de>
 <20131104200346.GA3066@sgi.com>
 <20131106131048.GC4877@suse.de>
 <20131107214838.GY3066@sgi.com>
 <20131108112054.GB5040@suse.de>
 <20131108221329.GD4236@sgi.com>
 <20131112212902.GA4725@sgi.com>
 <20131115000901.GB26002@suse.de>
 <20131115144504.GE26002@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131115144504.GE26002@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

> If the warning added by that patch does *not* trigger than can you also
> test this patch? It removes the barriers which should not be necessary
> and takes a reference tot he page before waiting on the lock. The
> previous version did not take the reference because otherwise the
> WARN_ON could not distinguish between a migration waiter and a surprise
> gup.

Sorry for the delay; been a bit busy.  I tested both of these patches on
top of this one (separately, of course):

http://www.spinics.net/lists/linux-mm/msg63919.html

I think that's the one you were referring to, if not send me a pointer
to the correct one and I'll give it another shot.  Both patches still
segfaulted, so it doesn't appear that either of these solved the
problem.  If you have anything else you'd like for me to try let me
know.

- Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
