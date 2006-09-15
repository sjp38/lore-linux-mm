Message-ID: <450AAA83.3040905@shadowen.org>
Date: Fri, 15 Sep 2006 14:28:35 +0100
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: [PATCH] Get rid of zone_table
References: <Pine.LNX.4.64.0609131340050.19059@schroedinger.engr.sgi.com>	 <1158180795.9141.158.camel@localhost.localdomain>	 <Pine.LNX.4.64.0609131425010.19380@schroedinger.engr.sgi.com> <1158184047.9141.164.camel@localhost.localdomain>
In-Reply-To: <1158184047.9141.164.camel@localhost.localdomain>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:
> Now that I think about it, we should have room to encode that thing
> inside of the section number on 32-bit platforms.
> 
> We have 32-bits of space, and we need to encode a number that is a
> maximum of 4 bits in size.  That leaves 28 bits minus the one that we
> use for the section present bit.  Our minimum section size on x86 is
> something like 64 or 128MB.  Let's say 64MB.  So, on a 64GB system, we
> only need 1k sections, and 10 bits.
> 
> So, the node number would almost certainly fit in the existing
> mem_section.  We'd just need to set it and mask it out.  
> 
> Andy, what do you think?

The flags field only has a 9 bit space for these value fields.  Into
which we normally shove NODE,ZONE.  With SPARSEMEM that is SECTION,ZONE
and so there is only room for 6-7 bits of information in this field.

The section table only contains an adjusted pointer to the mem_map for
that section?  We use the bottom two bits of that pointer for a couple
of flags.  I don't think there is any space in it.

Are you thinking of somewhere else?

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
