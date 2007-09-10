Date: Mon, 10 Sep 2007 12:25:13 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC 0/3] Recursive reclaim (on __PF_MEMALLOC)
In-Reply-To: <200709050916.04477.phillips@phunq.net>
Message-ID: <Pine.LNX.4.64.0709101220001.24735@schroedinger.engr.sgi.com>
References: <20070814142103.204771292@sgi.com> <200709050220.53801.phillips@phunq.net>
 <Pine.LNX.4.64.0709050334020.8127@schroedinger.engr.sgi.com>
 <200709050916.04477.phillips@phunq.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@phunq.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, David Miller <davem@davemloft.net>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Wed, 5 Sep 2007, Daniel Phillips wrote:

> > Na, that cannot be the case since it only activates when an OOM
> > condition would otherwise result.
> 
> I did not express myself clearly then.  Compared to our current 
> anti-deadlock patch set, you patch set is a regression.  Because 
> without help from some of our other patches, it does deadlock.  
> Obviously, we cannot have that.

Of course boundless allocations from interrupt / reclaim context will 
ultimately crash the system. To fix that you need to stop the networking 
layer from performing these.

> > Given your tests: It looks like we do not need it.
> 
> I do not agree with that line of thinking.  A single test load only 
> provides evidence, not proof.  Your approach is not obviously correct, 
> quite the contrary.  The tested patch set does not help atomic alloc at 
> all, which is clearly a problem we can hit, we just did not hit it this 
> time.

The patch is obviously correct because it provides memory where we used to 
fail.

> > We have a global dirty page limit already. I fully support Peters
> > work on dirty throttling.
> 
> Alas, I communicated exactly the opposite of what I intended.  We do not 
> like the global dirty limit.  It makes the vm complex and fragile, 
> unnecessarily.  We favor an approach that places less reliance on the 
> global dirty limit so that we can remove some of the fragile and hard 
> to support workarounds we have had to implement because of it.

So far our experience has just been the opposite and Peter's other patches 
demonstrate the same. Dirty limits make the VM stable and increase I/O 
performance.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
