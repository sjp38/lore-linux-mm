Date: Mon, 30 Jul 2007 22:00:15 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [rfc] [patch] mm: zone_reclaim fix for pseudo file systems
In-Reply-To: <20070730214756.c4211678.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0707302156440.30284@schroedinger.engr.sgi.com>
References: <20070727232753.GA10311@localdomain> <20070730132314.f6c8b4e1.akpm@linux-foundation.org>
 <20070731000138.GA32468@localdomain> <20070730172007.ddf7bdee.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0707301725280.25686@schroedinger.engr.sgi.com>
 <20070731015647.GC32468@localdomain> <Pine.LNX.4.64.0707301858280.26859@schroedinger.engr.sgi.com>
 <20070730192721.eb220a9d.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0707301934300.27364@schroedinger.engr.sgi.com>
 <20070730214756.c4211678.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ravikiran G Thirumalai <kiran@scalex86.org>, linux-mm@kvack.org, shai@scalex86.org
List-ID: <linux-mm.kvack.org>

On Mon, 30 Jul 2007, Andrew Morton wrote:

> On Mon, 30 Jul 2007 19:36:04 -0700 (PDT) Christoph Lameter <clameter@sgi.com> wrote:
> 
> > On Mon, 30 Jul 2007, Andrew Morton wrote:
> > 
> > > That makes sense, but any fix we do here won't fix things for regular
> > > reclaim.
> > 
> > Standard reclaim has the same issues. It uselessly keeps 
> > scanning the unreclaimable file backed pages.
> 
> Well it shouldn't.  That's what all_unreclaimable is for.  And it does
> work.  Or used to, five years ago.  Stuff like this has a habit of breaking
> because we don't have a test suite.

The current VM has never been able to handle it since we have never had 
logic to remove unreclaimable pages from the LRU.

Lets bring up the patchsets for the handling of unreclaimable pages up 
again (mlocked and anonymous/no swap) again and make sure that it also 
addresses the issue issue here so that we have a comprehensive solution.

I am going over my old patchsets anyways. Kiran: Did you have a look at 
the patches Nick and I did earlier this year for mlocked pages?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
