Date: Wed, 4 Apr 2007 14:26:06 +0200
From: Samuel Thibault <samuel.thibault@ens-lyon.org>
Subject: Re: mbind and alignment
Message-ID: <20070404122606.GF3638@implementation.labri.fr>
References: <20070402204202.GC3316@interface.famille.thibault.fr> <200704041352.04525.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <200704041352.04525.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

Andi Kleen, le Wed 04 Apr 2007 13:52:04 +0200, a ecrit :
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

Ok. I already sent a patch to the manpages maintainer.

Samuel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
