Date: Thu, 12 Jun 2008 02:08:46 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: repeatable slab corruption with LTP msgctl08
Message-Id: <20080612020846.c77761cd.akpm@linux-foundation.org>
In-Reply-To: <87mylrnj84.fsf@basil.nowhere.org>
References: <20080611221324.42270ef2.akpm@linux-foundation.org>
	<20080611233449.08e6eaa0.akpm@linux-foundation.org>
	<20080612010200.106df621.akpm@linux-foundation.org>
	<20080612011537.6146c41d.akpm@linux-foundation.org>
	<87mylrnj84.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Nadia Derbey <Nadia.Derbey@bull.net>, Manfred Spraul <manfred@colorfullife.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Thu, 12 Jun 2008 10:35:55 +0200 Andi Kleen <andi@firstfloor.org> wrote:

> Andrew Morton <akpm@linux-foundation.org> writes:
> >
> > Doing the same thing on 2.6.26-rc5-mm3, msgctl08 also runs to
> > completion, in 20.9 seconds.  So
> >
> > - it got slower
> 
> That is because it scales itself to the number of available msg queues.
> So with Nadia's patch there are more and it runs slower.
> 
> In fact it seems to start one process per message queue, so perhaps it's 
> just running out of processes or something. Ok it should not segfault.
> 
> BTW a great way to debug slab corruptions with LTP faster is to run with
> a slab thrasher stress module like http://firstfloor.org/~andi/crasher-26.diff
> 

Something like that might be needed.  I ran it again and it took 49
minutes to crash.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
