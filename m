Date: Wed, 5 Sep 2007 05:14:06 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC 0/3] Recursive reclaim (on __PF_MEMALLOC)
In-Reply-To: <20070905114242.GA19938@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0709050507050.9141@schroedinger.engr.sgi.com>
References: <20070814142103.204771292@sgi.com> <200709050220.53801.phillips@phunq.net>
 <Pine.LNX.4.64.0709050334020.8127@schroedinger.engr.sgi.com>
 <20070905114242.GA19938@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Daniel Phillips <phillips@phunq.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

On Wed, 5 Sep 2007, Nick Piggin wrote:

> However I really have an aversion to the near enough is good enough way of
> thinking. Especially when it comes to fundamental deadlocks in the VM. I
> don't know whether Peter's patch is completely clean yet, but fixing the
> fundamentally broken code has my full support.

Uhh. There are already numerous other issues why the VM is failing that is 
independent of Peter's approach.

> I hate it that there are theoretical bugs still left even if they would
> be hit less frequently than hardware failure. And that people are really
> happy to put even more of these things in :(

Theoretical bugs? Depends on one's creativity to come up with them I 
guess. So far we do not even get around to address the known issues and 
this multi subsystem patch has the potential of creating more.

> Anyway, as you know I like your patch and if that gives Peter a little
> more breathing space then it's a good thing. But I really hope he doesn't
> give up on it, and it should be merged one day.

Using the VM to throttle networking is a pretty bad thing because it 
assumes single critical user of memory. There are other consumers of 
memory and if you have a load that depends on other things than networking 
then you should not kill the other things that want memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
