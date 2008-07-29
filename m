Date: Tue, 29 Jul 2008 14:43:17 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] reserved-ram for pci-passthrough without VT-d capable hardware
Message-ID: <20080729124317.GK30344@one.firstfloor.org>
References: <1214232737-21267-1-git-send-email-benami@il.ibm.com> <1214232737-21267-2-git-send-email-benami@il.ibm.com> <20080625005739.GM6938@duo.random> <20080625011808.GN6938@duo.random> <20080729121125.GK11494@duo.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080729121125.GK11494@duo.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: benami@il.ibm.com, Avi Kivity <avi@qumranet.com>, Andrew Morton <akpm@linux-foundation.org>, amit.shah@qumranet.com, kvm@vger.kernel.org, aliguori@us.ibm.com, allen.m.kay@intel.com, muli@il.ibm.com, linux-mm@kvack.org, andi@firstfloor.org, tglx@linutronix.de, mingo@elte.hu
List-ID: <linux-mm.kvack.org>

> This is a port to current linux-2.6.git of the previous reserved-ram
> patch. Let me know if there's a chance to get this acked and
> included. Anything that isn't at compile time would require much

I still think runtime would be far better. Nobody really wants
a proliferation of more weird special kernel images.

> bigger changes just to parse the command line at 16bit realmode time

You could always do it with kexec if you think 16bit real mode is
too hard.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
