Date: Fri, 4 Jul 2003 11:29:34 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.5.74-mm1 fails to boot due to APIC trouble, 2.5.73mm3 works.
Message-ID: <20030704182934.GB955@holomorphy.com>
References: <20030703023714.55d13934.akpm@osdl.org> <3F054109.2050100@aitel.hist.no> <20030704093531.GA26348@holomorphy.com> <20030704095004.GB26348@holomorphy.com> <7910000.1057333295@[10.10.2.4]> <Pine.LNX.4.53.0307041139150.24383@montezuma.mastecende.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.53.0307041139150.24383@montezuma.mastecende.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zwane Mwaikambo <zwane@arm.linux.org.uk>
Cc: "Martin J. Bligh" <mbligh@aracnet.com>, Helge Hafting <helgehaf@aitel.hist.no>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

At some point in the past, I wrote:
>>> -#define APIC_BROADCAST_ID     (0x0f)
>>> +#define APIC_BROADCAST_ID     (0xff)

On Fri, 4 Jul 2003, Martin J. Bligh wrote:
>> So ... you've tested that change on a bigsmp machine, right? 
>> At least, provide some reasoning here. Like this comment further down the
>> patch ...

On Fri, Jul 04, 2003 at 11:47:03AM -0400, Zwane Mwaikambo wrote:
> That one is slightly worrying, yes.

It is not. It's a bound on physical APIC ID's. bigsmp is xAPIC-based.


At some point in the past, I wrote:
>>> +++ physid-2.5.74-1/include/asm-i386/mach-numaq/mach_apic.h	
>>> 2003-07-04 02:45:17.000000000 -0700
>>>
>>> -static inline cpumask_t apicid_to_cpu_present(int logical_apicid)
>>> +static inline physid_mask_t apicid_to_cpu_present(int logical_apicid)
>>>  {
>>>  	int node = apicid_to_node(logical_apicid);
>>>  	int cpu = __ffs(logical_apicid & 0xf);
>>>  
>>> -	return cpumask_of_cpu(cpu + 4*node);
>>> +	return physid_mask_of_physid(cpu + 4*node);
>>>  }

On Fri, 4 Jul 2003, Martin J. Bligh wrote:
>> Hmmmm. What are you using physical apicids here for? They seem
>> irrelevant to this function. 

On Fri, Jul 04, 2003 at 11:47:03AM -0400, Zwane Mwaikambo wrote:
> Urgh, it's really hard to determine what these functions really want half 
> the time. But that change does look wrong.

It's fine. It's used to generate a bitmask that's or'd with
phys_cpu_present_map.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
