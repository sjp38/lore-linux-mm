Date: Wed, 6 Jun 2001 10:12:37 -0600
Message-Id: <200106061612.f56GCbA14901@vindaloo.ras.ucalgary.ca>
From: Richard Gooch <rgooch@ras.ucalgary.ca>
Subject: Re: Requirement: swap = RAM x 2.5 ??
In-Reply-To: <3B1E52FC.C17C921F@mandrakesoft.com>
References: <3B1D5ADE.7FA50CD0@illusionary.com>
	<991815578.30689.1.camel@nomade>
	<20010606095431.C15199@dev.sportingbet.com>
	<0106061316300A.00553@starship>
	<200106061528.f56FSKa14465@vindaloo.ras.ucalgary.ca>
	<000701c0ee9f$515fd6a0$3303a8c0@einstein>
	<3B1E52FC.C17C921F@mandrakesoft.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeff Garzik <jgarzik@mandrakesoft.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christian =?iso-8859-1?Q?Borntr=E4ger?= <linux-kernel@borntraeger.net>, Derek Glidden <dglidden@illusionary.com>
List-ID: <linux-mm.kvack.org>

Jeff Garzik writes:
> 
> I'm sorry but this is a regression, plain and simple.
> 
> Previous versons of Linux have worked great on diskless workstations
> with NO swap.
> 
> Swap is "extra space to be used if we have it" and nothing else.

Sure. But Linux still works without swap. It's just that if you *do*
have swap, it works best with 2* RAM.

				Regards,

					Richard....
Permanent: rgooch@atnf.csiro.au
Current:   rgooch@ras.ucalgary.ca
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
