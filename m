Date: Wed, 30 Jul 2008 23:22:07 +0900
Subject: Re: [PATCH] reserved-ram for pci-passthrough without VT-d capable
	hardware
From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
In-Reply-To: <20080730135846.GB11494@duo.random>
References: <20080729131735.GM30344@one.firstfloor.org>
	<200807301150.44266.amit.shah@qumranet.com>
	<20080730135846.GB11494@duo.random>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <20080730232028R.tomof@acm.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: andrea@qumranet.com
Cc: amit.shah@qumranet.com, andi@firstfloor.org, benami@il.ibm.com, avi@qumranet.com, akpm@linux-foundation.org, kvm@vger.kernel.org, aliguori@us.ibm.com, allen.m.kay@intel.com, muli@il.ibm.com, linux-mm@kvack.org, tglx@linutronix.de, mingo@elte.hu
List-ID: <linux-mm.kvack.org>

On Wed, 30 Jul 2008 15:58:46 +0200
Andrea Arcangeli <andrea@qumranet.com> wrote:

> On Wed, Jul 30, 2008 at 11:50:43AM +0530, Amit Shah wrote:
> > * On Tuesday 29 July 2008 18:47:35 Andi Kleen wrote:
> > > > I'm not so interested to go there right now, because while this code
> > > > is useful right now because the majority of systems out there lacks
> > > > VT-d/iommu, I suspect this code could be nuked in the long
> > > > run when all systems will ship with that, which is why I kept it all
> > >
> > > Actually at least on Intel platforms and if you exclude the lowest end
> > > VT-d is shipping universally for quite some time now. If you
> > > buy a Intel box today or bought it in the last year the chances are pretty
> > > high that it has VT-d support.
> > 
> > I think you mean VT-x, which is virtualization extensions for the x86 
> > architecture. VT-d is virtualization extensions for devices (IOMMU).
> 
> I think Andi understood VT-d right but even if he was right that every
> reader of this email that is buying a new VT-x system today is also
> almost guaranteed to get a VT-d motherboard (which I disagree unless
> you buy some really expensive toy), there are current large
> installations of VT-x systems that lacks VT-d and that with recent
> current dual/quadcore cpus are very fast and will be used for the next
> couple of years and they will not upgrade just the motherboard to use
> pci-passthrough.

Today, very inexpensive desktops (for example, Dell OptiPlex 755) have
VT-d support.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
