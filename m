Subject: Re: Requirement: swap = RAM x 2.5 ??
References: <3B1D5ADE.7FA50CD0@illusionary.com>
	<991815578.30689.1.camel@nomade>
	<20010606095431.C15199@dev.sportingbet.com>
	<0106061316300A.00553@starship>
	<200106061528.f56FSKa14465@vindaloo.ras.ucalgary.ca>
	<000701c0ee9f$515fd6a0$3303a8c0@einstein>
	<3B1E52FC.C17C921F@mandrakesoft.com>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: 06 Jun 2001 12:42:03 -0600
In-Reply-To: <3B1E52FC.C17C921F@mandrakesoft.com>
Message-ID: <m1snhd5u2s.fsf@frodo.biederman.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeff Garzik <jgarzik@mandrakesoft.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christian Borntrdger <linux-kernel@borntraeger.net>, Derek Glidden <dglidden@illusionary.com>
List-ID: <linux-mm.kvack.org>

Jeff Garzik <jgarzik@mandrakesoft.com> writes:

> I'm sorry but this is a regression, plain and simple.
> 
> Previous versons of Linux have worked great on diskless workstations
> with NO swap.
> 
> Swap is "extra space to be used if we have it" and nothing else.

Given the slow speed of disks to use them efficiently when you are using
swap some additional rules apply.

In the worse case when swapping is being used you get:
Virtual Memory = RAM + (swap - RAM).

That cannot be improved.  You can increase your likely hood that that case won't
come up, but that is a different matter entirely.  

I suspect in practice that we are suffering more from lazy reclamation
of swap pages than from a more aggressive swap cache. 

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
