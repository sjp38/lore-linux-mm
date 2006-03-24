Message-ID: <442424FF.3090405@yahoo.com.au>
Date: Sat, 25 Mar 2006 03:57:35 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH][0/8] (Targeting 2.6.17) Posix memory locking and balanced
 mlock-LRU semantic
References: <bc56f2f0603200535s2b801775m@mail.gmail.com>	 <441FEF8D.7090905@yahoo.com.au> <bc56f2f0603240705y3b4abe3ej@mail.gmail.com>
In-Reply-To: <bc56f2f0603240705y3b4abe3ej@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Stone Wang <pwstone@gmail.com>
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Stone Wang wrote:
> 2006/3/21, Nick Piggin <nickpiggin@yahoo.com.au>:

>>In what way are we not now posix compliant now?
> 
> 
> Currently, Linux's mlock for example, may fail with  only part of its
> task finished.
> 
> While accroding to POSIX definition:
> 
> man mlock(2)
> 
> "
> RETURN VALUE
>        On success, mlock returns zero.  On error, -1 is returned, errno is set
>        appropriately, and no changes are made to  any  locks  in  the  address
>        space of the process.
> "
> 

Looks like you're right, so good catch. You should probably try to submit your
posix mlock patch by itself then. Make sure you look at the coding standards
though, and try to _really_ follow coding conventions of the file you're
modifying.

You also should make sure the patch works standalone (ie. not just as part of
a set). Oh, and introducing a new field in vma for a flag is probably not the
best option if you still have room in the vm_flags field.

And the patch changelog should contain the actual problem, and quote the
relevant part of the POSIX definition, if applicable.

Thanks,
Nick

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
