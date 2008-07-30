From: Amit Shah <amit.shah@qumranet.com>
Subject: Re: [PATCH] reserved-ram for pci-passthrough without VT-d capable hardware
Date: Wed, 30 Jul 2008 11:50:43 +0530
References: <1214232737-21267-1-git-send-email-benami@il.ibm.com> <20080729125312.GL11494@duo.random> <20080729131735.GM30344@one.firstfloor.org>
In-Reply-To: <20080729131735.GM30344@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200807301150.44266.amit.shah@qumranet.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrea Arcangeli <andrea@qumranet.com>, benami@il.ibm.com, Avi Kivity <avi@qumranet.com>, Andrew Morton <akpm@linux-foundation.org>, kvm@vger.kernel.org, aliguori@us.ibm.com, allen.m.kay@intel.com, muli@il.ibm.com, linux-mm@kvack.org, tglx@linutronix.de, mingo@elte.hu
List-ID: <linux-mm.kvack.org>

* On Tuesday 29 July 2008 18:47:35 Andi Kleen wrote:
> > I'm not so interested to go there right now, because while this code
> > is useful right now because the majority of systems out there lacks
> > VT-d/iommu, I suspect this code could be nuked in the long
> > run when all systems will ship with that, which is why I kept it all
>
> Actually at least on Intel platforms and if you exclude the lowest end
> VT-d is shipping universally for quite some time now. If you
> buy a Intel box today or bought it in the last year the chances are pretty
> high that it has VT-d support.

I think you mean VT-x, which is virtualization extensions for the x86 
architecture. VT-d is virtualization extensions for devices (IOMMU).

Amit

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
