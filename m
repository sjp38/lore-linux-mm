Date: Tue, 29 Jul 2008 15:17:35 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] reserved-ram for pci-passthrough without VT-d capable hardware
Message-ID: <20080729131735.GM30344@one.firstfloor.org>
References: <1214232737-21267-1-git-send-email-benami@il.ibm.com> <1214232737-21267-2-git-send-email-benami@il.ibm.com> <20080625005739.GM6938@duo.random> <20080625011808.GN6938@duo.random> <20080729121125.GK11494@duo.random> <20080729124317.GK30344@one.firstfloor.org> <20080729125312.GL11494@duo.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080729125312.GL11494@duo.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Andi Kleen <andi@firstfloor.org>, benami@il.ibm.com, Avi Kivity <avi@qumranet.com>, Andrew Morton <akpm@linux-foundation.org>, amit.shah@qumranet.com, kvm@vger.kernel.org, aliguori@us.ibm.com, allen.m.kay@intel.com, muli@il.ibm.com, linux-mm@kvack.org, tglx@linutronix.de, mingo@elte.hu
List-ID: <linux-mm.kvack.org>

> I'm not so interested to go there right now, because while this code
> is useful right now because the majority of systems out there lacks
> VT-d/iommu, I suspect this code could be nuked in the long
> run when all systems will ship with that, which is why I kept it all

Actually at least on Intel platforms and if you exclude the lowest end
VT-d is shipping universally for quite some time now. If you
buy a Intel box today or bought it in the last year the chances are pretty 
high that it has VT-d support.

> under #ifdef, and the changes to the other files outside ifdef are
> bugfixes needed if you want to kexec-relocate above 40m or so that
> should be kept.

You should split that out then into a separate patch.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
