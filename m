Message-ID: <4181168B.3060209@shadowen.org>
Date: Thu, 28 Oct 2004 16:55:55 +0100
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: [Lhms-devel] [2/7] 060 refactor setup_memory i386
References: <E1CNBE0-0006bV-ML@ladymac.shadowen.org> <41811566.2070200@us.ibm.com>
In-Reply-To: <41811566.2070200@us.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: lhms-devel@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:
> Andy Whitcroft wrote:
> 
>> +#ifndef CONFIG_DISCONTIGMEM
>> +void __init setup_bootmem_allocator(void);
>>  static unsigned long __init setup_memory(void)
>>  {
> 
> ...
> 
>> +#endif /* !CONFIG_DISCONTIGMEM */
>> +
>> +void __init setup_bootmem_allocator(void)
>> +{
> 
> 
> Won't this double define setup_bootmem_allocator() when 
> CONFIG_DISCONTIGMEM is disabled?

That is a pre-declaration.  There is only one copy of 
setup_bootmem_allocator() which is either used 'here' in the flatmem 
case, or from discontig.c in the DISCONTIGMEM case.  The order is 
backwards to minimise the overall diff; so I needed to declare it.

-apw
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
