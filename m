Date: Sat, 2 Jun 2007 10:23:40 +0300
Subject: Re: [PATCH] Document Linux Memory Policy
Message-ID: <20070602072340.GA14877@minantech.com>
References: <1180467234.5067.52.camel@localhost> <200705312243.20242.ak@suse.de> <20070601093803.GE10459@minantech.com> <200706011221.33062.ak@suse.de> <1180718106.5278.28.camel@localhost> <Pine.LNX.4.64.0706011140330.2643@schroedinger.engr.sgi.com> <20070601202829.GA14250@minantech.com> <Pine.LNX.4.64.0706011344260.4323@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0706011344260.4323@schroedinger.engr.sgi.com>
From: glebn@voltaire.com (Gleb Natapov)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andi Kleen <ak@suse.de>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, Jun 01, 2007 at 01:45:04PM -0700, Christoph Lameter wrote:
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

OK. This would be good enough for me (although I agree with Lee's approach and,
I suppose, we can track which process installed latest policy on the file's region
and remove it on process exit). But for the sake of consistency why not handle shmem
in the same way then? Do it Lee's way or do it your way but PLEASE do it the same
for all kind of memory regions! You are claiming that shmem is somehow special
because you can control access to it, but what about files? You surely
can control access to those. And about persistence of shmem policy I
don't see how this is useful for multiuser machine. I see some kind of
use for this in dedicated server, but this is exactly where it can be
achieved by other means.

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
