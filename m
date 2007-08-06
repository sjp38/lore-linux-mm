From: Daniel Phillips <phillips@phunq.net>
Subject: Re: [PATCH 02/10] mm: system wide ALLOC_NO_WATERMARK
Date: Mon, 6 Aug 2007 15:59:41 -0700
References: <20070806102922.907530000@chello.nl> <1186431992.7182.33.camel@twins> <Pine.LNX.4.64.0708061404300.3116@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0708061404300.3116@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200708061559.41680.phillips@phunq.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Steve Dickson <SteveD@redhat.com>
List-ID: <linux-mm.kvack.org>

On Monday 06 August 2007 14:05, Christoph Lameter wrote:
> > > That is possible if one
> > > would make sure that the network layer triggers reclaim once in a
> > > while.
> >
> > This does not make sense, we cannot reclaim from reclaim.
>
> But we should limit the amounts of allocation we do while performing
> reclaim...

Correct.  That is what the throttling part of these patches is about.  
In order to fix the vm writeout deadlock problem properly, two things 
are necessary:

  1) Throttle the vm writeout path to use a bounded amount of memory

  2) Provide access to a sufficiently large amount of reserve memory for 
each memory user in the vm writeout path

You can understand every detail of this patch set and the following ones 
coming from Peter in terms of those two requirements.

> F.e. refilling memory pools during reclaim should be disabled.

Actually, recursing into the vm should be disabled entirely but that is 
a rather deeply ingrained part of mm culture we do not propose to 
fiddle with just now.

Memory pools are refilled when the pool user frees some memory, not ever 
by the mm.

Regards,

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
