Date: Fri, 1 Jun 2007 23:28:29 +0300
Subject: Re: [PATCH] Document Linux Memory Policy
Message-ID: <20070601202829.GA14250@minantech.com>
References: <1180467234.5067.52.camel@localhost> <200705312243.20242.ak@suse.de> <20070601093803.GE10459@minantech.com> <200706011221.33062.ak@suse.de> <1180718106.5278.28.camel@localhost> <Pine.LNX.4.64.0706011140330.2643@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0706011140330.2643@schroedinger.engr.sgi.com>
From: glebn@voltaire.com (Gleb Natapov)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andi Kleen <ak@suse.de>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, Jun 01, 2007 at 11:43:57AM -0700, Christoph Lameter wrote:
> On Fri, 1 Jun 2007, Lee Schermerhorn wrote:
> 
> > Like Gleb, I find the different behaviors for different memory regions
> > to be unnatural.  Not because of the fraction of applications or
> > deployments that might use them, but because [speaking for customers] I
> > expect and want to be able to control placement of any object mapped
> > into an application's address space, subject to permissions and
> > privileges.
> 
> Same here and I wish we had a clean memory region based implementation.
> But that is just what your patches do *not* provide. Instead they are file 
> based. They should be memory region based.
Do you want a solution that doesn't associate memory policy with a file
(if a file is mapped shared and disk backed) like Lee's solution does, but
instead install it into VMA and respect the policy during pagecache page
allocation on behalf of the process? So two process should cooperate
(bind same part of a file to a same memory node in each process) to get
consistent result? If yes this will work for me.

I really hate to use shmget() for all the reasons you've listed in you
other mail and some more.

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
