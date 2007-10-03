Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l93GbG9w030437
	for <linux-mm@kvack.org>; Wed, 3 Oct 2007 12:37:16 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l93GbGZs665842
	for <linux-mm@kvack.org>; Wed, 3 Oct 2007 12:37:16 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l93GbFWd023175
	for <linux-mm@kvack.org>; Wed, 3 Oct 2007 12:37:16 -0400
Subject: Re: [Question] How to represent SYSTEM_RAM in kerenel/resouce.c
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20071003103136.addbe839.kamezawa.hiroyu@jp.fujitsu.com>
References: <20071003103136.addbe839.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain
Date: Wed, 03 Oct 2007 09:37:13 -0700
Message-Id: <1191429433.4939.49.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, andi@firstfloor.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, "tony.luck@intel.com" <tony.luck@intel.com>, Andrew Morton <akpm@linux-foundation.org>, pbadari@us.ibm.com, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-10-03 at 10:31 +0900, KAMEZAWA Hiroyuki wrote:
> 
> i386 and x86_64 registers System RAM as IORESOUCE_MEM |
> IORESOUCE_BUSY.
> ia64 registers System RAM as IORESOURCE_MEM.
> 
> Which is better ?

I think we should take system ram out of the iomem file, at least.

'struct resource' is a good, cross-platform structure to use for keeping
track of which memory we have where.  So, we can share that structure to
keep track of iomem, or memory hotplug state.  But, I'm not sure we
should be intermingling system RAM and iomem like we are now in the same
instance of the structure.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
