Message-ID: <45D5DE6F.6030604@student.ltu.se>
Date: Fri, 16 Feb 2007 17:40:15 +0100
From: Richard Knutsson <ricknu-0@student.ltu.se>
MIME-Version: 1.0
Subject: Re: [KJ] [PATCH] is_power_of_2 in ia64mm
References: <1171627435.6127.0.camel@wriver-t81fb058.linuxcoe>	<45D5C789.1090607@student.ltu.se> <jeire2nnik.fsf@sykes.suse.de>	<45D5D47F.3000303@student.ltu.se> <je3b56nlds.fsf@sykes.suse.de>
In-Reply-To: <je3b56nlds.fsf@sykes.suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andreas Schwab <schwab@suse.de>
Cc: Vignesh Babu BM <vignesh.babu@wipro.com>, Kernel Janitors List <kernel-janitors@lists.osdl.org>, linux-mm@kvack.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Andreas Schwab wrote:
> Richard Knutsson <ricknu-0@student.ltu.se> writes:
>   
>> Andreas Schwab wrote:
>>     
>>> Richard Knutsson <ricknu-0@student.ltu.se> writes:
>>>   
>>>       
>>>> Vignesh Babu BM wrote:
>>>>         
>>>>> @@ -175,7 +176,7 @@ static int __init hugetlb_setup_sz(char *str)
>>>>>  		tr_pages = 0x15557000UL;
>>>>>   	size = memparse(str, &str);
>>>>> -	if (*str || (size & (size-1)) || !(tr_pages & size) ||
>>>>> +	if (*str || !is_power_of_2(size) || !(tr_pages & size) ||
>>>>>  		size <= PAGE_SIZE ||
>>>>>  		size >= (1UL << PAGE_SHIFT << MAX_ORDER)) {
>>>>>  		printk(KERN_WARNING "Invalid huge page size specified\n");
>>>>>           
>>>> As we talked about before; is this really correct? !is_power_of_2(0) ==
>>>> true while (0 & (0-1)) == 0.
>>>>         
>>> size == 0 is also covered by the next two conditions, so the overall value
>>> does not change.
>>>       
>> Yes, but is it meant to state that 'size' is not a power of two?
>>     
>
> What else can it mean?
>   
What about !one_or_less_bit()? It has not been implemented (yet?) but 
been discussed. It ended by concluding that is_power_of_2() should be 
fixed up first and then we can see about it.
And as I stated before; !is_power_of_2(size) != (size & (size-1))! It 
may be a bug but then we have to be sure it is suppose to be the power of 2.

Richard Knutsson

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
