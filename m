Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id iAI2GW9G377160
	for <linux-mm@kvack.org>; Wed, 17 Nov 2004 21:16:32 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id iAI2GWQC201738
	for <linux-mm@kvack.org>; Wed, 17 Nov 2004 19:16:32 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id iAI2GVki005801
	for <linux-mm@kvack.org>; Wed, 17 Nov 2004 19:16:31 -0700
Subject: Re: [Lhms-devel] [RFC] fix for hot-add enabled SRAT/BIOS and numa
	KVA areas
From: keith <kmannth@us.ibm.com>
In-Reply-To: <20041117133315.92B7.YGOTO@us.fujitsu.com>
References: <1100659057.26335.125.camel@knk>
	 <20041117133315.92B7.YGOTO@us.fujitsu.com>
Content-Type: text/plain
Message-Id: <1100744190.26335.652.camel@knk>
Mime-Version: 1.0
Date: Wed, 17 Nov 2004 18:16:30 -0800
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <ygoto@us.fujitsu.com>
Cc: external hotplug mem list <lhms-devel@lists.sourceforge.net>, linux-mm <linux-mm@kvack.org>, Chris McDermott <lcm@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2004-11-17 at 14:33, Yasunori Goto wrote:
> Hello, Keith-san.
> 
> >   This chunk extends from the end of physical memory to the end of the
> > i386 address space.  If the following my physical memory is 0x2C0000. 
> > 
> > (From the boot messages)
> > Memory range 0x80000 to 0xC0000 (type 0x0) in proximity domain 0x01 enabled
> > Memory range 0x100000 to 0x2C0000 (type 0x0) in proximity domain 0x01 enabled
> > Memory range 0x2C0000 to 0x1000000 (type 0x0) in proximity domain 0x01 enabled and removable
> >   
> >   These memory ranges I believe to be valid according to what I know
> > about the SRAT and the ACPI 2.0c specs.  (I am not an ACPI expert please
> > correct me if I am wrong!)
> 
> I also think this is valid. Probably the firmware of x445 thought, 
> if enabled bit of SRAT is off, any other information of its area
> will not be trusted.
> So, there is no way to distinguish the machine can't attach more memory
> from it can do it (just there is no memory AT BOOT TIME.)
> So, third area in this boot message just indicates "possibility" of hotadd
> memory.
> But e820 probably indicates just memory areas which 
> are already connected on the board, right?

This is what I believe.  The e820 is the only true source of how much
memory is present in the system.  The SRAT just shows what the memory
layout is.  The SRAT is correct there is the possibility of memory being
in this zone.  

BTW: I can't toggle the SRAT enable bit in my bios.  I get it all the
time.    

> (IIRC, there is no mention about if enable bit of SRAT is off
>  in SRAT spec.)
> 
> BTW, I have a question.
>   - Can x445 be attached memory without removing the node?
>     In my concern machine, there is no physical space to
>     hot add or exchange memory without physical removing
>     the node. But, this SRAT table indicate that
>     all of proximity is 0x01....
>     Or is it just logical attachment?

My memory add works as follows.  I can physically add dimms in one of my
nodes.  I do not have to remove any node(cec) from my system.  Just open
up the case in insert dmmms into a empty memory bank.  

Thanks,
  Keith Mannthey   

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
