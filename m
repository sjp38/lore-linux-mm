Date: Fri, 17 Dec 2004 20:37:24 +0100
From: Andi Kleen <ak@suse.de>
Subject: Re: [patch] CONFIG_ARCH_HAS_ATOMIC_UNSIGNED
Message-ID: <20041217193724.GA13542@wotan.suse.de>
References: <E1Cf6EG-00015y-00@kernel.beaverton.ibm.com> <20041217061150.GF12049@wotan.suse.de> <Pine.LNX.4.58.0412170827280.17806@server.graphe.net> <20041217163308.GE14229@wotan.suse.de> <Pine.LNX.4.58.0412171118430.20902@server.graphe.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0412171118430.20902@server.graphe.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <christoph@lameter.com>
Cc: Andi Kleen <ak@suse.de>, Dave Hansen <haveblue@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Dec 17, 2004 at 11:26:49AM -0800, Christoph Lameter wrote:
> On Fri, 17 Dec 2004, Andi Kleen wrote:
> 
> > > Put the order of the page there for compound pages instead of having that
> > > in index?
> >
> > That would waste memory on the 64bit architectures that cannot tolerate
> > 32bit atomic flags or on true 32bit architecture.
> 
> Would be great to have 64 bit atomic support to fill this hole then.

I think you lost me.   How would that help?

To fill the hole you would need a 4 byte member with padding to move around,
but there isn't one. You cannot also just add one because it would waste 
memory on 32bit archs and other 64bit archs.

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
