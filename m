Message-ID: <40CFB99A.8080508@yahoo.com.au>
Date: Wed, 16 Jun 2004 13:08:10 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: mmap() > phys mem problem
References: <Pine.LNX.4.44.0406141501340.7351-100000@pygar.sc.orionmulti.com> <40CE6ADE.4040903@yahoo.com.au>
In-Reply-To: <40CE6ADE.4040903@yahoo.com.au>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ron Maeder <rlm@orionmulti.com>
Cc: riel@surriel.com, akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> Ron Maeder wrote:
> 
>> I tried upping /proc/sys/vm/min_free_kbytes to 4096 as suggested 
>> below, with the same results (grinding to a halt, out of mem).
>>
>> Any other suggestions?  Thanks for your help.
>>
> 
> Hmm. Maybe ask linux-net and/or the NFS guys?
> 
> You need to know the maximum amount of memory that your setup
> might need in order to write out one page.
> 
> There might also be ways to reduce this, like reducing NFS
> transfer sizes or network buffers... I dunno.
> 

Actually no, I don't think that will help. I have an
idea that might help. Stay tuned :)

For the time being, would it be at all possible to
work around it using your msync hack, turning swap on,
or doing read/write IO?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
