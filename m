Date: Thu, 8 Mar 2007 18:31:01 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [RFC][PATCH 3/5] mm: RCUify vma lookup
Message-ID: <20070308173101.GB16834@elte.hu>
References: <20070306013815.951032000@taijtu.programming.kicks-ass.net> <20070306014211.293824000@taijtu.programming.kicks-ass.net> <20070306022319.GF23845@wotan.suse.de> <20070306083632.GA10540@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070306083632.GA10540@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Christoph Lameter <clameter@engr.sgi.com>, "Paul E. McKenney" <paulmck@us.ibm.com>
List-ID: <linux-mm.kvack.org>

* Nick Piggin <npiggin@suse.de> wrote:

> > This is a funny scheme you're trying to do in order to try to avoid 
> > rwsems. [...]

yeah, i think you are pretty much right.

> ... though I must add that it seems like a very cool patchset and I 
> hope I can get time to go through it more thoroughly! Nice work ;)

:) We'll figure out something else. The fundamental problem of vma 
lookup scalability is still there, and -rt here isnt really anything 
special, it's more like an 'early warning system for scalability 
problems' that shows us on single-CPU systems the issues of 1024-CPU 
systems ;-)

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
