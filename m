Message-ID: <45D5D47F.3000303@student.ltu.se>
Date: Fri, 16 Feb 2007 16:57:51 +0100
From: Richard Knutsson <ricknu-0@student.ltu.se>
MIME-Version: 1.0
Subject: Re: [KJ] [PATCH] is_power_of_2 in ia64mm
References: <1171627435.6127.0.camel@wriver-t81fb058.linuxcoe>	<45D5C789.1090607@student.ltu.se> <jeire2nnik.fsf@sykes.suse.de>
In-Reply-To: <jeire2nnik.fsf@sykes.suse.de>
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
>   
>> Vignesh Babu BM wrote:
>>     
>>> @@ -175,7 +176,7 @@ static int __init hugetlb_setup_sz(char *str)
>>>  		tr_pages = 0x15557000UL;
>>>   	size = memparse(str, &str);
>>> -	if (*str || (size & (size-1)) || !(tr_pages & size) ||
>>> +	if (*str || !is_power_of_2(size) || !(tr_pages & size) ||
>>>  		size <= PAGE_SIZE ||
>>>  		size >= (1UL << PAGE_SHIFT << MAX_ORDER)) {
>>>  		printk(KERN_WARNING "Invalid huge page size specified\n");
>>>
>>>   
>>>       
>> As we talked about before; is this really correct? !is_power_of_2(0) ==
>> true while (0 & (0-1)) == 0.
>>     
>
> size == 0 is also covered by the next two conditions, so the overall value
> does not change.
>   
Yes, but is it meant to state that 'size' is not a power of two? 
Otherwise, imho, it should be left as-is.

Richard Knutsson

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
