Message-ID: <20061209143341.90545.qmail@web52308.mail.yahoo.com>
Date: Sat, 9 Dec 2006 06:33:41 -0800 (PST)
From: John Fusco <fusco_john@yahoo.com>
Subject: Re: Making PCI Memory Cachable
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

----- Original Message ----
  

From: Andi Kleen <ak@suse.de>
  

To: John Fusco <fusco_john@yahoo.com>
  

Cc: linux-mm@kvack.org
  

Sent: Wednesday, December 6, 2006 4:16:27 PM
  

Subject: Re: Making PCI Memory Cachable
  


  

On Tuesday 28 November 2006 15:02, John Fusco wrote:
  

> I have numerous custom PCI devices that implement SRAM or DRAM on the 
  

> PCI bus. I would like to explore making this memory cachable in the 
  

> hopes that writes to memory can be done from user space and will be done 
  

> in bursts rather than single cycles.
  


  

You want write combining, not cacheable. The only way to do 
  

this currently is to set a MTRR. See Documentation/mtrr.txt 
  

by default.
  


  

>     b) The memory is cachable, but the chipset is throttling the bursts
  


  

The normal cache coherency protocol doesn't work over PCI
  


  

-Andi

Thanks for the reply.

I am aware of the MTRRs, but I was hoping for a more elegant solution. 

BTW, why won't cache coherency protocol work over PCI? It has commands to support this, such as "memory read line" and "memory write line". Is it that Linux does not allow memory outside of RAM to be cacheable?

John








 
____________________________________________________________________________________
Do you Yahoo!?
Everyone is raving about the all-new Yahoo! Mail beta.
http://new.mail.yahoo.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
