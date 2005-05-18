Date: Wed, 18 May 2005 09:51:01 -0700
From: Matt Tolentino <metolent@snoqualmie.dp.intel.com>
Message-Id: <200505181651.j4IGp1VB026987@snoqualmie.dp.intel.com>
Subject: Re: [patch 4/4] add x86-64 specific support for sparsemem
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ak@muc.de, metolent@snoqualmie.dp.intel.com
Cc: akpm@osdl.org, apw@shadowen.org, haveblue@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>From ak@muc.de  Wed May 18 09:33:00 2005
>
>> @@ -400,9 +401,12 @@ static __init void parse_cmdline_early (
>>  }
>>  
>>  #ifndef CONFIG_NUMA
>> -static void __init contig_initmem_init(void)
>> +static void __init
>> +contig_initmem_init(unsigned long start_pfn, unsigned long end_pfn)
>>  {
>>          unsigned long bootmap_size, bootmap; 
>> +
>> +	memory_present(0, start_pfn, end_pfn);
>
>Watch indentation.

Weird.  I just looked again and this is tabbed properly, although
the rest of the lines in this function are indented with individual
spaces.  

>Rest looks good.

Thanks!

matt
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
