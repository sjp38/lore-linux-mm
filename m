Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j6SIPPIY537234
	for <linux-mm@kvack.org>; Thu, 28 Jul 2005 14:25:25 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j6SIPSb4168302
	for <linux-mm@kvack.org>; Thu, 28 Jul 2005 12:25:28 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j6SIPOYU003920
	for <linux-mm@kvack.org>; Thu, 28 Jul 2005 12:25:24 -0600
Subject: Re: [patch] mm: Ensure proper alignment for node_remap_start_pfn
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20050728181421.GA3842@localhost.localdomain>
References: <20050728004241.GA16073@localhost.localdomain>
	 <20050727181724.36bd28ed.akpm@osdl.org>
	 <20050728013134.GB23923@localhost.localdomain>
	 <1122571226.23386.44.camel@localhost>
	 <20050728181421.GA3842@localhost.localdomain>
Content-Type: text/plain
Date: Thu, 28 Jul 2005 11:25:22 -0700
Message-Id: <1122575122.20800.32.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ravikiran G Thirumalai <kiran@scalex86.org>
Cc: Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, shai@scalex86.org
List-ID: <linux-mm.kvack.org>

On Thu, 2005-07-28 at 11:14 -0700, Ravikiran G Thirumalai wrote:
> SRAT need not guarantee any alignment at all in the memory affinity 
> structure (the address in 64-bit byte address)

The Summit machines (the only x86 user of the SRAT) have other hardware
guarantees about alignment, so I guess that's why we've never
encountered it.  Are you using the SRAT on non-Summit hardware?  That
doesn't seem possible:

arch/i386/Kconfig:
        config ACPI_SRAT
                bool
                default y
                depends on NUMA && (X86_SUMMIT || X86_GENERICARCH)
        
> And yes, there are x86-numa
> machines that run the latest kernel tree and face this problem.

I didn't say "run the latest kernel tree".  *In* the latest kernel
tree :)

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
