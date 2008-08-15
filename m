Message-ID: <48A5AADE.1050808@sciatl.com>
Date: Fri, 15 Aug 2008 09:12:14 -0700
From: C Michael Sundius <Michael.sundius@sciatl.com>
MIME-Version: 1.0
Subject: Re: sparsemem support for mips with highmem
References: <48A4AC39.7020707@sciatl.com> <1218753308.23641.56.camel@nimitz>	 <48A4C542.5000308@sciatl.com>  <20080815080331.GA6689@alpha.franken.de> <1218815299.23641.80.camel@nimitz>
In-Reply-To: <1218815299.23641.80.camel@nimitz>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Thomas Bogendoerfer <tsbogend@alpha.franken.de>, linux-mm@kvack.org, linux-mips@linux-mips.org, jfraser@broadcom.com, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:
> On Fri, 2008-08-15 at 10:03 +0200, Thomas Bogendoerfer wrote:
>   
>> On Thu, Aug 14, 2008 at 04:52:34PM -0700, C Michael Sundius wrote:
>>     
>>> +
>>> +#ifndef CONFIG_64BIT
>>> +#define SECTION_SIZE_BITS       27	/* 128 MiB */
>>> +#define MAX_PHYSMEM_BITS        31	/* 2 GiB   */
>>> +#else
>>>  #define SECTION_SIZE_BITS       28
>>>  #define MAX_PHYSMEM_BITS        35
>>> +#endif
>>>       
>> why is this needed ?
>>     
>
> I'm sure Michael can speak to the specifics.  But, in general, making
> SECTION_SIZE_BITS smaller is good if you have lots of small holes in
> memory.  It does this at the cost if increasing the size of the
> mem_section[] array.
>
> MAX_PHYSMEM_BITS should be as as small as possible, but not so small
> that it restricts the amount of RAM that your systems
> support.  i>>?Increasing it has the effect of increasing the size of the
> mem_section[] array.
>
> My guess would be that Michael knew that his 32-bit MIPS platform only
> ever has 2GB of memory.  He also knew that its holes (or RAM) come in
> 128MB sections.  This configuration lets him save the most amount of
> memory with SPARSEMEM.
>
> Michael, I *guess* you could also include a wee bit on how you chose
> your numbers in the documentation.  Not a big deal, though.
>
> -- Dave
>
>   
yes,  actually the top two bits are used in MIPS as segment bits.
For 64 bit MIPS machines there is a bigger physical address space.
In our case, we used either 128MiB or 256MiB blocks or RAM and they
are separated by holes at least that big. It seemed reasonable that that was
the biggest value that I could make it.

One thing that I had thought about and also came up when my peers here
reviewed my changes was that we probably could put those bit numbers
(at the very least the segment size) in the .config file.

we decided that the power that be might have had a reason for that and
we left it not wanting to meddle with the other arch's.

Dave, do you have a comment about that?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
