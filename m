Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1Kx1NS-0006fD-EQ
	for linux-mm@kvack.org; Mon, 03 Nov 2008 15:30:02 +0000
Received: from one.firstfloor.org ([213.235.205.2])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Mon, 03 Nov 2008 15:30:02 +0000
Received: from andi by one.firstfloor.org with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Mon, 03 Nov 2008 15:30:02 +0000
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [RESEND] x86: add memory hotremove config option
Date: 03 Nov 2008 16:22:27 +0100
Message-ID: <m0od0wzvf0.fsf@localhost.localdomain>
References: <20081031175203.GA7483@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Gary Hade <garyhade@us.ibm.com> writes:
> 
> Memory hotremove functionality can currently be configured into
> the ia64, powerpc, and s390 kernels.  This patch makes it possible
> to configure the memory hotremove functionality into the x86
> kernel as well.

You still didn't say how this is actually going to work and what
it is good for? See thread last time. The big difference is that
the powerpc and s390 kernels have the needed Hypervisor interfaces, x86
has not (not sure about ia64)

iirc the code is useless for hardware based memory hotplug (because it
doesn't free full nodes) and not useful for hypervisor based memory
hotplug without additional drivers (and actual hypervisor support of
course)

Enabling the sysfs interface now is just giving a promise to the user
that you cannot hold. Also it makes the kernel bigger without actually
giving useful functionality.

If some x86 hypervisor gains support for this I think the interface
shouldn't be through sysfs, but controlled through the respective PV drivers
which need to be involved anyways.

-Andi

-- 
ak@linux.intel.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
