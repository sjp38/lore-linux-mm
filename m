Date: Fri, 17 Dec 2004 17:33:08 +0100
From: Andi Kleen <ak@suse.de>
Subject: Re: [patch] CONFIG_ARCH_HAS_ATOMIC_UNSIGNED
Message-ID: <20041217163308.GE14229@wotan.suse.de>
References: <E1Cf6EG-00015y-00@kernel.beaverton.ibm.com> <20041217061150.GF12049@wotan.suse.de> <Pine.LNX.4.58.0412170827280.17806@server.graphe.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0412170827280.17806@server.graphe.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <christoph@lameter.com>
Cc: Andi Kleen <ak@suse.de>, Dave Hansen <haveblue@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Dec 17, 2004 at 08:27:58AM -0800, Christoph Lameter wrote:
> 
> On Fri, 17 Dec 2004, Andi Kleen wrote:
> 
> > struct page {
> >         page_flags_t flags;             /* Atomic flags, some possibly
> >                                          * updated asynchronously */
> >
> > 			<------------ what to do with the 4 byte padding here?
> >
> 
> Put the order of the page there for compound pages instead of having that
> in index?

That would waste memory on the 64bit architectures that cannot tolerate
32bit atomic flags or on true 32bit architecture.

Also what's the problem of having it in index?

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
