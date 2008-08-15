Message-ID: <48A5B9F1.3080201@sciatl.com>
Date: Fri, 15 Aug 2008 10:16:33 -0700
From: C Michael Sundius <Michael.sundius@sciatl.com>
MIME-Version: 1.0
Subject: Re: sparsemem support for mips with highmem
References: <48A4AC39.7020707@sciatl.com> <1218753308.23641.56.camel@nimitz> <48A4C542.5000308@sciatl.com> <20080815080331.GA6689@alpha.franken.de> <1218815299.23641.80.camel@nimitz> <48A5AADE.1050808@sciatl.com> <20080815163302.GA9846@alpha.franken.de>
In-Reply-To: <20080815163302.GA9846@alpha.franken.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-mips@linux-mips.org, jfraser@broadcom.com, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

Thomas Bogendoerfer wrote:
> On Fri, Aug 15, 2008 at 09:12:14AM -0700, C Michael Sundius wrote:
>   
>> yes,  actually the top two bits are used in MIPS as segment bits.
>>     
>
> you are confusing virtual addresses with physcial addresses. There
> are even 32bit CPU, which could address more than 4GB physical
> addresses via TLB entries.
>
> Thomas.
>
>   
Ah, your right. thanks.  "but it's not necessar*il*y a good idea". That 
is to say, we don't put
memory above 2 GiB. No need to make the mem_section[] array bigger than 
need be.

This gives further credence for it to be a configurable in Kconfig as well.

Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
