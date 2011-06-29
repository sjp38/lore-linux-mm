Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8ADE76B0012
	for <linux-mm@kvack.org>; Wed, 29 Jun 2011 13:07:37 -0400 (EDT)
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e1.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p5TGtYS0007460
	for <linux-mm@kvack.org>; Wed, 29 Jun 2011 12:55:34 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p5TH7ZN6134508
	for <linux-mm@kvack.org>; Wed, 29 Jun 2011 13:07:35 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p5TD6P0a002072
	for <linux-mm@kvack.org>; Wed, 29 Jun 2011 10:06:26 -0300
Subject: Re: [PATCH 00/10] mm: Linux VM Infrastructure to support Memory
 Power Management
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20110629130038.GA7909@in.ibm.com>
References: <1306499498-14263-1-git-send-email-ankita@in.ibm.com>
	 <20110629130038.GA7909@in.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 29 Jun 2011 10:06:24 -0700
Message-ID: <1309367184.11430.594.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ankita Garg <ankita@in.ibm.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-pm@lists.linux-foundation.org, svaidy@linux.vnet.ibm.com, thomas.abraham@linaro.org, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Matthew Garrett <mjg59@srcf.ucam.org>, Arjan van de Ven <arjan@infradead.org>

I was kinda hoping for something a bit simpler than that.  I'd boil down
what you were saying to this:

     1. The kernel must be aware of how the pieces of hardware are
        mapped in to the system's physical address space
     2. The kernel must have a mechanism in place to minimize access to
        specific pieces of hardware 
     3. For destructive power-down operations, the kernel should have a
        mechanism in place to ensure that no valuable data is contained
        in the memory to be powered down.

Is that complete?

On Wed, 2011-06-29 at 18:30 +0530, Ankita Garg wrote:
> 1) Dynamic Power Transition: The memory controller can have the ability
> to automatically transition regions of memory into lower power states
> when they are devoid of references for a pre-defined threshold amount of
> time. Memory contents are preserved in the low power states and accessing
> memory that is at a low power state takes a latency hit.
> 
> 2) Dynamic Power Off: If a region is free/unallocated, the software can
> indicate to the controller to completely turn off power to a certain
> region. Memory contents are lost and hence the software has to be
> absolutely sure about the usage statistics of the particular region. This
> is a runtime capability, where the required amount of memory can be
> powered 'ON' to match the workload demands.
> 
> 3) Partial Array Self-Refresh (PASR): If a certain regions of memory is
> free/unallocated, the software can indicate to the controller to not
> refresh that region when the system goes to suspend-to-ram state and
> thereby save standby power consumption.

(3) is simply a subset of (2), but with the additional restriction that
the power off can only occur during a suspend operation.  

Let's say we fully implemented support for (2).  What would be missing
to support PASR?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
