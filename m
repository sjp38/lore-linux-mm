Message-ID: <3B1E572B.1CEEF41B@mandrakesoft.com>
Date: Wed, 06 Jun 2001 12:15:39 -0400
From: Jeff Garzik <jgarzik@mandrakesoft.com>
MIME-Version: 1.0
Subject: Re: Requirement: swap = RAM x 2.5 ??
References: <3B1D5ADE.7FA50CD0@illusionary.com>
		<991815578.30689.1.camel@nomade>
		<20010606095431.C15199@dev.sportingbet.com>
		<0106061316300A.00553@starship>
		<200106061528.f56FSKa14465@vindaloo.ras.ucalgary.ca>
		<000701c0ee9f$515fd6a0$3303a8c0@einstein>
		<3B1E52FC.C17C921F@mandrakesoft.com> <200106061612.f56GCbA14901@vindaloo.ras.ucalgary.ca>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Richard Gooch <rgooch@ras.ucalgary.ca>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christian =?iso-8859-1?Q?Borntr=E4ger?= <linux-kernel@borntraeger.net>, Derek Glidden <dglidden@illusionary.com>
List-ID: <linux-mm.kvack.org>

Richard Gooch wrote:
> 
> Jeff Garzik writes:
> >
> > I'm sorry but this is a regression, plain and simple.
> >
> > Previous versons of Linux have worked great on diskless workstations
> > with NO swap.
> >
> > Swap is "extra space to be used if we have it" and nothing else.
> 
> Sure. But Linux still works without swap. It's just that if you *do*
> have swap, it works best with 2* RAM.

Yes, but that's not the point of the discussion.  Currently 2*RAM is
more of a requirement than a recommendation.

-- 
Jeff Garzik      | Andre the Giant has a posse.
Building 1024    |
MandrakeSoft     |
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
