Message-ID: <44B11D99.5090303@yahoo.com.au>
Date: Mon, 10 Jul 2006 01:15:37 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Commenting out out_of_memory() function in __alloc_pages()
References: <BKEKJNIHLJDCFGDBOHGMIEFJDCAA.abum@aftek.com>
In-Reply-To: <BKEKJNIHLJDCFGDBOHGMIEFJDCAA.abum@aftek.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Abu M. Muttalib" <abum@aftek.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Robert Hancock <hancockr@shaw.ca>, chase.venters@clientec.com, kernelnewbies@nl.linux.org, linux-newbie@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Abu M. Muttalib wrote:
>>Abu, I guess you have turned on CONFIG_EMBEDDED and disabled everything
>>you don't need, turned off full sized data structures, removed everything
>>else you don't need from the kernel config, turned off kernel debugging
>>(especially slab debugging).
> 
> 
> Do you mean that I have configured kernel with CONFIG_EMBEDDED option??

I am guessing you have, if you a concerned about memory usage. Have you?

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
