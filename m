Date: Fri, 27 Jun 2008 08:46:47 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 0/5] [RFC] Conversion of reverse map locks to semaphores
In-Reply-To: <1214556789.2801.19.camel@twins.programming.kicks-ass.net>
Message-ID: <Pine.LNX.4.64.0806270844040.12950@schroedinger.engr.sgi.com>
References: <20080626003632.049547282@sgi.com>
 <1214556789.2801.19.camel@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-mm@kvack.org, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

On Fri, 27 Jun 2008, Peter Zijlstra wrote:

> > Also it seems that a semaphore helps RT and should avoid busy spinning
> > on systems where these locks experience significant contention.
> 
> Please be careful with the wording here. Semaphores are evil esp for RT.
> But luckily you're referring to a sleeping RW lock, which we call
> RW-semaphore (but is not an actual semaphore).
> 
> You really scared some people saying this ;-)

Well we use the term semaphore for sleeping locks in the kernel it seems.

Maybe you could get a patch done that renames the struct to 
sleeping_rw_lock or so? That would finally clear the air. This is the 
second or third time we talk about a semaphore not truly being a 
semaphore.

> Depending on the contention stats you could try an adaptive spin on the
> readers. I doubt adaptive spins on the writer would work out well, with
> the natural plenty-ness of readers..

That depends on the frequency of lock taking and the contention. If you 
have a rw lock then you would assume that writers are rare so this is 
likely okay.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
