Subject: Re: [RFC][PATCH] Re: Linux 2.4.4-ac10
References: <Pine.LNX.4.33.0105191743000.393-100000@mikeg.weiden.de>
Reply-To: zlatko.calusic@iskon.hr
From: Zlatko Calusic <zlatko.calusic@iskon.hr>
Date: 20 May 2001 15:44:12 +0200
In-Reply-To: <Pine.LNX.4.33.0105191743000.393-100000@mikeg.weiden.de>
Message-ID: <8766ew16fn.fsf@atlas.iskon.hr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Galbraith <mikeg@wen-online.de>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Rik van Riel <riel@conectiva.com.br>, Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Mike Galbraith <mikeg@wen-online.de> writes:

> Hi,
> 
> On Fri, 18 May 2001, Stephen C. Tweedie wrote:
> 
> > That's the main problem with static parameters.  The problem you are
> > trying to solve is fundamentally dynamic in most cases (which is also
> > why magic numbers tend to suck in the VM.)
> 
> Magic numbers might be sucking some performance right now ;-)
> 
[snip]

I like your patch, it improves performance somewhat and makes things
more smooth and also code is simpler.

Anyway, 2.4.5-pre3 is quite debalanced and it has even broken some
things that were working properly before. For instance, swapoff now
deadlocks the machine (even with your patch applied).

Unfortunately, I have failed to pinpoint the exact problem, but I'm
confident that kernel goes in some kind of loop (99% system time, just
before deadlock). Anybody has some guidelines how to debug kernel if
you're running X?

Also in all recent kernels, if the machine is swapping, swap cache
grows without limits and is hard to recycle, but then again that is
a known problem.
-- 
Zlatko
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
