Date: Wed, 30 May 2007 10:41:44 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Document Linux Memory Policy
In-Reply-To: <1180541849.5850.30.camel@localhost>
Message-ID: <Pine.LNX.4.64.0705301040560.1195@schroedinger.engr.sgi.com>
References: <1180467234.5067.52.camel@localhost>
 <Pine.LNX.4.64.0705291247001.26308@schroedinger.engr.sgi.com>
 <200705292216.31102.ak@suse.de> <1180541849.5850.30.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Andi Kleen <ak@suse.de>, mtk-manpages@gmx.net, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 30 May 2007, Lee Schermerhorn wrote:

> > Also the big difference to MPOL_BIND is that it is not strict and will fall 
> > back like the default policy.
> 
> Right.  And since the API argument is a node mask, one might want to
> know what happens if more than one node is specified.  On the other
> hand, we could play hardball and reject the call if more than one is
> specified.

I think we would like to reject the call if more than one node is 
specified.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
