From: Andi Kleen <ak@suse.de>
Subject: Re: Making PCI Memory Cachable
Date: Wed, 6 Dec 2006 23:16:27 +0100
References: <456C4182.4020302@yahoo.com>
In-Reply-To: <456C4182.4020302@yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200612062316.27898.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: John Fusco <fusco_john@yahoo.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
