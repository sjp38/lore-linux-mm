Date: Sat, 18 Dec 2004 07:50:55 +0100
From: Andi Kleen <ak@suse.de>
Subject: Re: [patch] CONFIG_ARCH_HAS_ATOMIC_UNSIGNED
Message-ID: <20041218065055.GA5829@wotan.suse.de>
References: <E1Cf6EG-00015y-00@kernel.beaverton.ibm.com> <20041217061150.GF12049@wotan.suse.de> <Pine.LNX.4.58.0412170827280.17806@server.graphe.net> <20041217163308.GE14229@wotan.suse.de> <Pine.LNX.4.58.0412171118430.20902@server.graphe.net> <20041217193724.GA13542@wotan.suse.de> <Pine.LNX.4.58.0412171410240.23925@server.graphe.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0412171410240.23925@server.graphe.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <christoph@lameter.com>
Cc: Andi Kleen <ak@suse.de>, Dave Hansen <haveblue@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Dec 17, 2004 at 02:11:59PM -0800, Christoph Lameter wrote:
> On Fri, 17 Dec 2004, Andi Kleen wrote:
> 
> > On Fri, Dec 17, 2004 at 11:26:49AM -0800, Christoph Lameter wrote:
> > > On Fri, 17 Dec 2004, Andi Kleen wrote:
> > >
> > > > > Put the order of the page there for compound pages instead of having that
> > > > > in index?
> > > >
> > > > That would waste memory on the 64bit architectures that cannot tolerate
> > > > 32bit atomic flags or on true 32bit architecture.
> > >
> > > Would be great to have 64 bit atomic support to fill this hole then.
> >
> > I think you lost me.   How would that help?
> 
> It would fill the hole on 64 bits if atomic_t would have the native word
> size.

The problem is that that 64bit atomic_t type would end up unaligned.
While that would work in theory on x86-64 I suspect it would be slow even
there. And it would probably not work anywhere else.

And as Dave said they plan to use the upper 32bit of flags for 
CONFIG_NONLINEAR anyways, so it's not even possible.

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
