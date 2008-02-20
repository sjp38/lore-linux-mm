MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <18364.16552.455371.242369@stoffel.org>
Date: Wed, 20 Feb 2008 10:00:56 -0500
From: "John Stoffel" <john@stoffel.org>
Subject: Re: [PATCH] Document huge memory/cache overhead of memory controller
 in Kconfig
In-Reply-To: <47BC2275.4060900@linux.vnet.ibm.com>
References: <20080220122338.GA4352@basil.nowhere.org>
	<47BC2275.4060900@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Andi Kleen <andi@firstfloor.org>, akpm@osdl.org, torvalds@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "Balbir" == Balbir Singh <balbir@linux.vnet.ibm.com> writes:

Balbir> Andi Kleen wrote:
>> Document huge memory/cache overhead of memory controller in Kconfig
>> 
>> I was a little surprised that 2.6.25-rc* increased struct page for the memory
>> controller.  At least on many x86-64 machines it will not fit into a single
>> cache line now anymore and also costs considerable amounts of RAM. 

Balbir> The size of struct page earlier was 56 bytes on x86_64 and with 64 bytes it
Balbir> won't fit into the cacheline anymore? Please also look at
Balbir> http://lwn.net/Articles/234974/

>> At earlier review I remembered asking for a external data structure for this.
>> 
>> It's also quite unobvious that a innocent looking Kconfig option with a 
>> single line Kconfig description has such a negative effect.
>> 
>> This patch attempts to document these disadvantages at least so that users
>> configuring their kernel can make a informed decision.
>> 
>> Cc: balbir@linux.vnet.ibm.com
>> 
>> Signed-off-by: Andi Kleen <ak@suse.de>
>> 
>> Index: linux/init/Kconfig
>> ===================================================================
>> --- linux.orig/init/Kconfig
>> +++ linux/init/Kconfig
>> @@ -394,6 +394,14 @@ config CGROUP_MEM_CONT
>> Provides a memory controller that manages both page cache and
>> RSS memory.
>> 
>> +	  Note that setting this option increases fixed memory overhead
>> +	  associated with each page of memory in the system by 4/8 bytes
>> +	  and also increases cache misses because struct page on many 64bit
>> +	  systems will not fit into a single cache line anymore.
>> +
>> +	  Only enable when you're ok with these trade offs and really
>> +	  sure you need the memory controller.
>> +

I know this is a pedantic comment, but why the heck is it called such
a generic term as "Memory Controller" which doesn't give any
indication of what it does.

Shouldn't it be something like "Memory Quota Controller", or "Memory
Limits Controller"?

Also, the Kconfig name "CGROUP_MEM_CONT" is just wrong, it should be
"CGROUP_MEM_CONTROLLER", just spell it out so it's clear what's up.

It took me a bunch of reading of Documentation/controllers/memory.txt
to even start to understand what the purpose of this was.  The
document could also use a re-writing to include a clear introduction
at the top to explain "what" a memory controller is.  

Something which talks about limits, resource management, quotas, etc
would be nice.  

Thanks,
John

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
