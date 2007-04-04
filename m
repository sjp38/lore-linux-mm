Date: Wed, 4 Apr 2007 18:19:28 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: mbind and alignment
In-Reply-To: <200704041352.04525.ak@suse.de>
Message-ID: <Pine.LNX.4.64.0704041808490.3891@blonde.wat.veritas.com>
References: <20070402204202.GC3316@interface.famille.thibault.fr>
 <200704041352.04525.ak@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Samuel Thibault <samuel.thibault@ens-lyon.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 4 Apr 2007, Andi Kleen wrote:
> > 
> > So one of those should probably be done to free people from headaches:
> > 
> > - document "start" requirement in the manual page
> > - require len to be aligned too, and document the requirements in the
> >   manual page
> > - drop the "start" requirement and just round down the page + adjust
> >   size automatically.
> 
> This annoyed me in the past too. The kernel should have done that alignment
> by itself. But changing it now would be a bad idea because it would
> produce programs that run on newer kernels but break on olders.
> Documenting it is the only sane option left.

It is annoying, but consistent with all mm's msyscall()s: they all
(I bet you'll now point me to an exception or two!) fail if start
is not page aligned, but silently round up len.  UNIX did it like
that.  Documentation is indeed the answer.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
