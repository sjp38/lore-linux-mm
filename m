Date: Fri, 1 Jun 2007 14:58:56 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Document Linux Memory Policy
In-Reply-To: <1180732232.5278.152.camel@localhost>
Message-ID: <Pine.LNX.4.64.0706011456090.5009@schroedinger.engr.sgi.com>
References: <1180467234.5067.52.camel@localhost>  <200705312243.20242.ak@suse.de>
 <20070601093803.GE10459@minantech.com>  <200706011221.33062.ak@suse.de>
 <1180718106.5278.28.camel@localhost>  <Pine.LNX.4.64.0706011140330.2643@schroedinger.engr.sgi.com>
  <20070601202829.GA14250@minantech.com>  <Pine.LNX.4.64.0706011344260.4323@schroedinger.engr.sgi.com>
 <1180732232.5278.152.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Gleb Natapov <glebn@voltaire.com>, Andi Kleen <ak@suse.de>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 1 Jun 2007, Lee Schermerhorn wrote:

> But, what if the processes install different policies... if they're NOT
> cooperating.  This was your previous objection.  In fact, you've used
> just the scenario that Gleb describes as an objection--that different
> tasks could have different policies in their address spaces.  Not a
> problem if the policy is shared.  Let one task do the setup.  Done!  It
> just works.  Keep those uncooperative tasks away from your file.
> 
> What happened to consistency? ;-)

It is consistent with page cache pages being able to be "faulted" in 
either by buffered I/O or mmapped I/O of to an arbitrary node. So the 
application does not have the expectation that the pages must be on 
certain nodes. This is the same for shared anonymous pages. It would be
fully consistent across all uses of vma based policiues.

The new pages are allocated in the context of the vma's memory policy. And 
the applicable policy depends on the task doing the allocations. 
Again consistent semantics with how anonymous pages are handled.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
