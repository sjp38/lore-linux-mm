Received: from fujitsu3.fujitsu.com (localhost [127.0.0.1])
	by fujitsu3.fujitsu.com (8.12.10/8.12.9) with ESMTP id iAHMY7pa000397
	for <linux-mm@kvack.org>; Wed, 17 Nov 2004 14:34:07 -0800 (PST)
Date: Wed, 17 Nov 2004 14:33:43 -0800
From: Yasunori Goto <ygoto@us.fujitsu.com>
Subject: Re: [Lhms-devel] [RFC] fix for hot-add enabled SRAT/BIOS and numa KVA areas
In-Reply-To: <1100659057.26335.125.camel@knk>
References: <1100659057.26335.125.camel@knk>
Message-Id: <20041117133315.92B7.YGOTO@us.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: keith <kmannth@us.ibm.com>
Cc: external hotplug mem list <lhms-devel@lists.sourceforge.net>, linux-mm <linux-mm@kvack.org>, Chris McDermott <lcm@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Hello, Keith-san.

>   This chunk extends from the end of physical memory to the end of the
> i386 address space.  If the following my physical memory is 0x2C0000. 
> 
> (From the boot messages)
> Memory range 0x80000 to 0xC0000 (type 0x0) in proximity domain 0x01 enabled
> Memory range 0x100000 to 0x2C0000 (type 0x0) in proximity domain 0x01 enabled
> Memory range 0x2C0000 to 0x1000000 (type 0x0) in proximity domain 0x01 enabled and removable
>   
>   These memory ranges I believe to be valid according to what I know
> about the SRAT and the ACPI 2.0c specs.  (I am not an ACPI expert please
> correct me if I am wrong!)

I also think this is valid. Probably the firmware of x445 thought, 
if enabled bit of SRAT is off, any other information of its area
will not be trusted.
So, there is no way to distinguish the machine can't attach more memory
from it can do it (just there is no memory AT BOOT TIME.)
So, third area in this boot message just indicates "possibility" of hotadd
memory.
But e820 probably indicates just memory areas which 
are already connected on the board, right?

(IIRC, there is no mention about if enable bit of SRAT is off
 in SRAT spec.)

BTW, I have a question.
  - Can x445 be attached memory without removing the node?
    In my concern machine, there is no physical space to
    hot add or exchange memory without physical removing
    the node. But, this SRAT table indicate that
    all of proximity is 0x01....
    Or is it just logical attachment?

Thanks.

-- 
Yasunori Goto <ygoto at us.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
