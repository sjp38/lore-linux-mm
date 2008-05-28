Date: Wed, 28 May 2008 11:13:35 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 03/23] hugetlb: modular state
Message-ID: <20080528091335.GD2630@wotan.suse.de>
References: <20080525142317.965503000@nick.local0.net> <20080525143452.408189000@nick.local0.net> <1211920687.12036.11.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1211920687.12036.11.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: linux-mm@kvack.org, kniht@us.ibm.com, andi@firstfloor.org, nacc@us.ibm.com, abh@cray.com, joachim.deguara@amd.com, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, May 27, 2008 at 03:38:07PM -0500, Adam Litke wrote:
> Phew.  At last I made it to the end of this one :)  It seems okay to me
> though.  Have you done any performance testing on this patch series yet?
> I don't expect the hstate structure to introduce any measurable
> performance degradation, but it would be nice to have some numbers to
> back up that educated guess.

Haven't seen any noticable performance differences, but I don't know
that I'm doing particularly interesting testing. Would be nice to
get some results with HPC or databases or something that actually
test the code.

I'd say with HUGE_MAX_HSTATE == 1, the compiler _should_ be able to
constant fold much of it away. There would be a few more pointer
dereferences (eg to get hstate from inode or vma)... if that _really_
matters, we could special case HUGE_MAX_HSTATE == 1 in some places
to bring performance back up.



> 
> Acked-by: Adam Litke <agl@us.ibm.com>
> 
> On Mon, 2008-05-26 at 00:23 +1000, npiggin@suse.de wrote:
> > plain text document attachment (hugetlb-modular-state.patch)
> > Large, but rather mechanical patch that converts most of the hugetlb.c
> > globals into structure members and passes them around.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
