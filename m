Message-ID: <417EC3E9.5020406@kolumbus.fi>
Date: Wed, 27 Oct 2004 00:38:49 +0300
From: =?ISO-8859-1?Q?Mika_Penttil=E4?= <mika.penttila@kolumbus.fi>
MIME-Version: 1.0
Subject: Re: [Lhms-devel] Re: 150 nonlinear
References: <E1CJYc0-0000aK-A8@ladymac.shadowen.org>	 <1098815779.4861.26.camel@localhost>  <417EA06B.5040609@kolumbus.fi>	 <1098819748.5633.0.camel@localhost>  <417EB684.1060100@kolumbus.fi>	 <1098824141.6188.1.camel@localhost>  <417EBFB3.5000803@kolumbus.fi> <1098826023.7172.4.camel@localhost>
In-Reply-To: <1098826023.7172.4.camel@localhost>
Content-Transfer-Encoding: 8BIT
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Andy Whitcroft <apw@shadowen.org>, lhms <lhms-devel@lists.sourceforge.net>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:

>On Tue, 2004-10-26 at 14:20, Mika Penttila wrote:
>  
>
>>"There are two problems that are being solved: having a sparse layout
>>requiring splitting up mem_map (solved by discontigmem and your
>>nonlinear), and supporting non-linear phys to virt relationships (Dave
>>M's implentation which does the mem_map split as well)."
>>
>>
>>so what's the split?
>>    
>>
>
>So, mem_map is normally laid out so that, if you have 1GB of memory, the
>memory for 0x00000000 is at mem_map[0], and the memory for the last page
>(at 1GB - 1 page) is at mem_map[1<<30 / PAGE_SIZE - 1].  
>
>That's fine and dandy for most systems.  But, imagine that you have some
>memory on a funky machine where you have 2GB of memory, but it is laid
>out like this:
>
>    0-1 GB - first 1 GB
>  1-100 GB - empty
>100-101 GB - second 1 GB
>
>Then, you'd need to have mem_map sized the same as a 101GB system on
>your dinky 2GB system (disregard the ia64 implementation).
>
>The split I'm referring to is cutting mem_map[] up into pieces for each
>contiguous section of memory.  
>
>Make sense?
>
>-- Dave
>
>
>  
>
Yes, I see Dave M's approarch is doing this, but isn't Andy's as well? 
What's the key differences between these two?

--Mika


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
