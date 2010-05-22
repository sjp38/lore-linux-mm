Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3E0C560032A
	for <linux-mm@kvack.org>; Sat, 22 May 2010 14:18:58 -0400 (EDT)
Message-ID: <4BF8200E.6020807@cesarb.net>
Date: Sat, 22 May 2010 15:18:54 -0300
From: Cesar Eduardo Barros <cesarb@cesarb.net>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] mm/swapfile.c: better messages for swap_info_get
References: <4BF81D87.6010506@cesarb.net> <1274551731-4534-1-git-send-email-cesarb@cesarb.net> <20100522181352.GB26778@liondog.tnic>
In-Reply-To: <20100522181352.GB26778@liondog.tnic>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Borislav Petkov <bp@alien8.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Em 22-05-2010 15:13, Borislav Petkov escreveu:
>> @@ -522,16 +522,16 @@ static struct swap_info_struct *swap_info_get(swp_entry_t entry)
>>   	return p;
>>
>>   bad_free:
>> -	printk(KERN_ERR "swap_free: %s%08lx\n", Unused_offset, entry.val);
>> +	printk(KERN_ERR "swap_info_get: %s%08lx\n", Unused_offset, entry.val);
>
> Why not let the compiler do it for ya:
>
> 	printk(KERN_ERR "%s: %s%08lx\n", __func__, Unused_offset, entry.val);
>
> ?... etc.

See the third patch. This function becomes swap_info_get_unlocked(), and 
swap_info_get() becomes a small wrapper around it. Yet, I still want to 
keep printing swap_info_get: in the error message (whether it is locked 
or not makes no difference from the point of view of the error messsage).

-- 
Cesar Eduardo Barros
cesarb@cesarb.net
cesar.barros@gmail.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
