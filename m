Subject: Re: [PATCH] Document Linux Memory Policy
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0706011344260.4323@schroedinger.engr.sgi.com>
References: <1180467234.5067.52.camel@localhost>
	 <200705312243.20242.ak@suse.de> <20070601093803.GE10459@minantech.com>
	 <200706011221.33062.ak@suse.de> <1180718106.5278.28.camel@localhost>
	 <Pine.LNX.4.64.0706011140330.2643@schroedinger.engr.sgi.com>
	 <20070601202829.GA14250@minantech.com>
	 <Pine.LNX.4.64.0706011344260.4323@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Fri, 01 Jun 2007 17:10:32 -0400
Message-Id: <1180732232.5278.152.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Gleb Natapov <glebn@voltaire.com>, Andi Kleen <ak@suse.de>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2007-06-01 at 13:45 -0700, Christoph Lameter wrote:
> On Fri, 1 Jun 2007, Gleb Natapov wrote:
> 
> > > Same here and I wish we had a clean memory region based implementation.
> > > But that is just what your patches do *not* provide. Instead they are file 
> > > based. They should be memory region based.
> > Do you want a solution that doesn't associate memory policy with a file
> > (if a file is mapped shared and disk backed) like Lee's solution does, but
> > instead install it into VMA and respect the policy during pagecache page
> > allocation on behalf of the process? So two process should cooperate
> 
> Right.

> 
> > (bind same part of a file to a same memory node in each process) to get
> > consistent result? If yes this will work for me.
> 
> Yes.

But, what if the processes install different policies... if they're NOT
cooperating.  This was your previous objection.  In fact, you've used
just the scenario that Gleb describes as an objection--that different
tasks could have different policies in their address spaces.  Not a
problem if the policy is shared.  Let one task do the setup.  Done!  It
just works.  Keep those uncooperative tasks away from your file.

What happened to consistency? ;-)

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
