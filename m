Date: Thu, 7 Apr 2005 01:40:49 +0200 (CEST)
From: Roman Zippel <zippel@linux-m68k.org>
Subject: Re: [PATCH 1/4] create mm/Kconfig for arch-independent memory options
In-Reply-To: <1112821319.14584.28.camel@localhost>
Message-ID: <Pine.LNX.4.61.0504070133380.25131@scrub.home>
References: <E1DIViE-0006Kf-00@kernel.beaverton.ibm.com>  <42544D7E.1040907@linux-m68k.org>
 <1112821319.14584.28.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, 6 Apr 2005, Dave Hansen wrote:

> On Wed, 2005-04-06 at 22:58 +0200, Roman Zippel wrote:
> > Dave Hansen wrote:
> > > --- memhotplug/mm/Kconfig~A6-mm-Kconfig	2005-04-04 09:04:48.000000000 -0700
> > > +++ memhotplug-dave/mm/Kconfig	2005-04-04 10:15:23.000000000 -0700
> > > @@ -0,0 +1,25 @@
> > > +choice
> > > +	prompt "Memory model"
> > > +	default FLATMEM
> > > +	default SPARSEMEM if ARCH_SPARSEMEM_DEFAULT
> > > +	default DISCONTIGMEM if ARCH_DISCONTIGMEM_DEFAULT
> > 
> > Does this really have to be a user visible option and can't it be
> > derived from other values? The help text entries are really no help at all.
> 
> I hope that this selection will replace the current DISCONTIGMEM prompts
> in the individual architectures.  That way, you won't get a net increase
> in the number of prompts.

Why is this choice needed at all? Why would one choose SPARSEMEM over 
DISCONTIGMEM? Help texts such as "If unsure, choose <something else>" make 
the complete config option pretty useless.

bye, Roman
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
