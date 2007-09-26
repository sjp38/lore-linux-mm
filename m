Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp02.au.ibm.com (8.13.1/8.13.1) with ESMTP id l8Q8IuJh023132
	for <linux-mm@kvack.org>; Wed, 26 Sep 2007 18:18:56 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8Q8IpJR4235490
	for <linux-mm@kvack.org>; Wed, 26 Sep 2007 18:18:54 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8Q8HLTn028118
	for <linux-mm@kvack.org>; Wed, 26 Sep 2007 18:17:21 +1000
Message-ID: <46FA15C7.9020603@linux.vnet.ibm.com>
Date: Wed, 26 Sep 2007 13:48:15 +0530
From: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: 2.6.23-rc8-mm1 - powerpc memory hotplug link failure
References: <20070925014625.3cd5f896.akpm@linux-foundation.org> <46F968C2.7080900@linux.vnet.ibm.com> <1190757715.13955.40.camel@dyn9047017100.beaverton.ibm.com>
In-Reply-To: <1190757715.13955.40.camel@dyn9047017100.beaverton.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, kamezawa.hiroyu@jp.fujitsu.com, Andy Whitcroft <apw@shadowen.org>, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Badari Pulavarty wrote:
> On Wed, 2007-09-26 at 01:30 +0530, Kamalesh Babulal wrote:
>> Hi Andrew,
>>
>> The 2.6.23-rc8-mm1 kernel linking fails on the powerpc (P5+) box
>>
>>   CC      init/version.o
>>   LD      init/built-in.o
>>   LD      .tmp_vmlinux1
>> drivers/built-in.o: In function `memory_block_action':
>> /root/scrap/linux-2.6.23-rc8/drivers/base/memory.c:188: undefined reference to `.remove_memory'
>> make: *** [.tmp_vmlinux1] Error 1
>>
> 
> I ran into the same thing earlier. Here is the fix I made.
> 
> Thanks,
> Badari
> 
> Memory hotplug remove is currently supported only on IA64
> 
> Signed-off-by: Badari Pulavarty <pbadari@us.ibm.com>
> 
> Index: linux-2.6.23-rc8/mm/Kconfig
> ===================================================================
> --- linux-2.6.23-rc8.orig/mm/Kconfig	2007-09-25 14:44:03.000000000 -0700
> +++ linux-2.6.23-rc8/mm/Kconfig	2007-09-25 14:44:48.000000000 -0700
> @@ -143,6 +143,7 @@ config MEMORY_HOTREMOVE
>  	bool "Allow for memory hot remove"
>  	depends on MEMORY_HOTPLUG
>  	depends on MIGRATION
> +	depends on (IA64)
> 
>  # Heavily threaded applications may benefit from splitting the mm-wide
>  # page_table_lock, so that faults on different parts of the user address
> 
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

Hi Badari,

Thanks, your patch fixed the problem.

-- 
Thanks & Regards,
Kamalesh Babulal,
Linux Technology Center,
IBM, ISTL.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
