Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j8UFNlnA008076
	for <linux-mm@kvack.org>; Fri, 30 Sep 2005 11:23:47 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j8UFNlon090254
	for <linux-mm@kvack.org>; Fri, 30 Sep 2005 11:23:47 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j8UFNlvJ026724
	for <linux-mm@kvack.org>; Fri, 30 Sep 2005 11:23:47 -0400
Subject: Re: [PATCH 00/07][RFC] i386: NUMA emulation
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20050930073232.10631.63786.sendpatchset@cherry.local>
References: <20050930073232.10631.63786.sendpatchset@cherry.local>
Content-Type: text/plain
Date: Fri, 30 Sep 2005 08:23:44 -0700
Message-Id: <1128093825.6145.26.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Magnus Damm <magnus@valinux.co.jp>
Cc: linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2005-09-30 at 16:33 +0900, Magnus Damm wrote:
> These patches implement NUMA memory node emulation for regular i386 PC:s.
> 
> NUMA emulation could be used to provide coarse-grained memory resource control
> using CPUSETS. Another use is as a test environment for NUMA memory code or
> CPUSETS using an i386 emulator such as QEMU.

This patch set basically allows the "NUMA depends on SMP" dependency to
be removed.  I'm not sure this is the right approach.  There will likely
never be a real-world NUMA system without SMP.  So, this set would seem
to include some increased (#ifdef) complexity for supporting SMP && !
NUMA, which will likely never happen in the real world.

Also, I worry that simply #ifdef'ing things out like CPUsets' update
means that CPUsets lacks some kind of abstraction that it should have
been using in the first place.  An #ifdef just papers over the real
problem.  

I think it would likely be cleaner if the approach was to emulate an SMP
NUMA system where each NUMA node simply doesn't have all of its CPUs
online.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
