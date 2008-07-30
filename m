Date: Wed, 30 Jul 2008 16:38:26 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH] reserved-ram for pci-passthrough without VT-d capable
	hardware
Message-ID: <20080730143826.GI11494@duo.random>
References: <1214232737-21267-1-git-send-email-benami@il.ibm.com> <20080729125312.GL11494@duo.random> <20080729131735.GM30344@one.firstfloor.org> <200807301150.44266.amit.shah@qumranet.com> <20080730135846.GB11494@duo.random> <489077A6.7090105@qumranet.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <489077A6.7090105@qumranet.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dor Laor <dor.laor@qumranet.com>
Cc: Amit Shah <amit.shah@qumranet.com>, Andi Kleen <andi@firstfloor.org>, benami@il.ibm.com, Avi Kivity <avi@qumranet.com>, Andrew Morton <akpm@linux-foundation.org>, kvm@vger.kernel.org, aliguori@us.ibm.com, allen.m.kay@intel.com, muli@il.ibm.com, linux-mm@kvack.org, tglx@linutronix.de, mingo@elte.hu
List-ID: <linux-mm.kvack.org>

On Wed, Jul 30, 2008 at 05:16:06PM +0300, Dor Laor wrote:
> In addition KVM is used in embedded too and things are slower there, we 
> know of a specific use case (production) that demands
> 1:1 mapping and can't use VT-d

Since you mentioned this ;), I take opportunity to add that those
embedded usages are the ones that are totally fine with the compile
time passthrough-guest-ram decision, instead of a boot time
decision. Those host kernels will likely have RT patches (KVM works
great with preempt-RT indeed) and in turn the compile time ram
selection is the least of their problems as you can imagine ;). So you
can see my patch as an embedded-build option, similar to "Configure
standard kernel features (for small systems)" and no distro is
shipping new kernels with that feature on either.

Than if we decide 1:1 should have larger userbase instead of only the
people that knows what they're doing (i.e. 1:1 guest can destroy
linux-hypervisor) we can always add a bit of strtol parsing to 16bit
kernelloader.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
