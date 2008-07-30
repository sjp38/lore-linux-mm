Date: Wed, 30 Jul 2008 15:58:46 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH] reserved-ram for pci-passthrough without VT-d capable
	hardware
Message-ID: <20080730135846.GB11494@duo.random>
References: <1214232737-21267-1-git-send-email-benami@il.ibm.com> <20080729125312.GL11494@duo.random> <20080729131735.GM30344@one.firstfloor.org> <200807301150.44266.amit.shah@qumranet.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200807301150.44266.amit.shah@qumranet.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Amit Shah <amit.shah@qumranet.com>
Cc: Andi Kleen <andi@firstfloor.org>, benami@il.ibm.com, Avi Kivity <avi@qumranet.com>, Andrew Morton <akpm@linux-foundation.org>, kvm@vger.kernel.org, aliguori@us.ibm.com, allen.m.kay@intel.com, muli@il.ibm.com, linux-mm@kvack.org, tglx@linutronix.de, mingo@elte.hu
List-ID: <linux-mm.kvack.org>

On Wed, Jul 30, 2008 at 11:50:43AM +0530, Amit Shah wrote:
> * On Tuesday 29 July 2008 18:47:35 Andi Kleen wrote:
> > > I'm not so interested to go there right now, because while this code
> > > is useful right now because the majority of systems out there lacks
> > > VT-d/iommu, I suspect this code could be nuked in the long
> > > run when all systems will ship with that, which is why I kept it all
> >
> > Actually at least on Intel platforms and if you exclude the lowest end
> > VT-d is shipping universally for quite some time now. If you
> > buy a Intel box today or bought it in the last year the chances are pretty
> > high that it has VT-d support.
> 
> I think you mean VT-x, which is virtualization extensions for the x86 
> architecture. VT-d is virtualization extensions for devices (IOMMU).

I think Andi understood VT-d right but even if he was right that every
reader of this email that is buying a new VT-x system today is also
almost guaranteed to get a VT-d motherboard (which I disagree unless
you buy some really expensive toy), there are current large
installations of VT-x systems that lacks VT-d and that with recent
current dual/quadcore cpus are very fast and will be used for the next
couple of years and they will not upgrade just the motherboard to use
pci-passthrough.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
