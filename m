Received: from anjala.mit.edu (arvind@ANJALA.MIT.EDU [18.251.3.144])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA31705
	for <linux-mm@kvack.org>; Wed, 7 Apr 1999 17:08:46 -0400
Message-ID: <19990407170743.A22786@anjala.mit.edu>
Date: Wed, 7 Apr 1999 17:07:43 -0400
From: Arvind Sankar <arvinds@MIT.EDU>
Subject: Re: [patch] arca-vm-2.2.5
Reply-To: Arvind Sankar <arvinds@MIT.EDU>
References: <199904062253.PAA12352@piglet.twiddle.net> <Pine.HPP.3.96.990407174343.13413D-100000@gra-ux1.iram.es>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.HPP.3.96.990407174343.13413D-100000@gra-ux1.iram.es>; from Gabriel Paubert on Wed, Apr 07, 1999 at 05:59:04PM +0200
Sender: owner-linux-mm@kvack.org
To: Gabriel Paubert <paubert@iram.es>, davem@redhat.com
Cc: mingo@chiara.csoma.elte.hu, sct@redhat.com, andrea@e-mind.com, cel@monkey.org, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 07, 1999 at 05:59:04PM +0200, Gabriel Paubert wrote:
> 
> 
> On Tue, 6 Apr 1999, David Miller wrote:
> 
> >    Date: Wed, 7 Apr 1999 00:49:18 +0200 (CEST)
> >    From: Ingo Molnar <mingo@chiara.csoma.elte.hu>
> > 
> >    It should be 'inode >> 8' (which is done by the log2
> >    solution). Unless i'm misunderstanding something.
> > 
> > Consider that:
> > 
> > (((unsigned long) inode) >> (sizeof(struct inode) & ~ (sizeof(struct inode) - 1)))
> > 
> > sort of approximates this and avoids the funny looking log2 macro. :-)
> 
> May I disagree ? Compute this expression in the case sizeof(struct inode) 
> is a large power of 2. Say 0x100, the shift count becomes (0x100 & ~0xff),
> or 0x100. Shifts by amounts larger than or equal to the word size are
> undefined in C AFAIR (and in practice on most architectures which take
> the shift count modulo some power of 2). 
> 

typo there, I guess. the >> should be an integer division. Since the divisor is
a constant power of 2, the compiler will optimize it into a shift.

--  arvind
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
