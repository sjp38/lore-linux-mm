Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id A5DFC6B004D
	for <linux-mm@kvack.org>; Mon, 25 May 2009 21:03:19 -0400 (EDT)
Message-ID: <4A1B4072.1040709@oracle.com>
Date: Mon, 25 May 2009 18:05:54 -0700
From: Randy Dunlap <randy.dunlap@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Warn if we run out of swap space
References: <20090524144056.0849.A69D9226@jp.fujitsu.com> <4A1A057A.3080203@oracle.com> <20090526093917.6846.A69D9226@jp.fujitsu.com>
In-Reply-To: <20090526093917.6846.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, akpm@linux-foundation.org, linux-mm@kvack.org, Pavel Machek <pavel@ucw.cz>, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro wrote:
>>>> @@ -410,6 +411,10 @@ swp_entry_t get_swap_page(void)
>>>>  	}
>>>>
>>>>  	nr_swap_pages++;
>>>> +	if (!printed) {
>>>> +		printed = 1;
>>>> +		printk(KERN_WARNING "All of swap is in use. Some pages cannot be swapped out.");
>>>> +	}
>>> Why don't you use WARN_ONCE()?
>> Someone earlier in this patch thread (maybe Pavel?) commented that
>> WARN_ONCE() would cause a stack dump and that would be too harsh,
>> especially for users.  I.e., just the message is needed here, not a
>> stack dump.
> 
> Ah, makes sense.
> I agree with you.
> 
> So, adding patch description is better?

Do you mean put that info in the patch description?
That would be OK.

>>> lumpy reclaim on no swap system makes this warnings, right?
>>> if so, I think it's a bit annoy.
>>>
>>>>  noswap:
>>>>  	spin_unlock(&swap_lock);
>>>>  	return (swp_entry_t) {0};


-- 
~Randy
LPC 2009, Sept. 23-25, Portland, Oregon
http://linuxplumbersconf.org/2009/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
