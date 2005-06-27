Message-ID: <42BFB2BC.7070402@yahoo.com.au>
Date: Mon, 27 Jun 2005 18:03:08 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: VFS scalability
References: <42BF9CD1.2030102@yahoo.com.au> <42BFA014.9090604@yahoo.com.au> <p733br4w9uw.fsf@verdi.suse.de> <42BFABD7.5000006@yahoo.com.au> <20050627074414.GB14251@wotan.suse.de>
In-Reply-To: <20050627074414.GB14251@wotan.suse.de>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:
> On Mon, Jun 27, 2005 at 05:33:43PM +1000, Nick Piggin wrote:
> 
>>>Maybe adding a prefetch for it at the beginning of sys_read() 
>>>might help, but then with 64CPUs writing to parts of the inode
>>>it will always thrash no matter how many prefetches.
>>>
>>
>>True. I'm just not sure what is causing the bouncing - I guess
>>->f_count due to get_file()?
> 
> 
> That's in the file, not in the inode. It must be some inode field.
> I don't know which one.
> 

Oh yes, my mistake.

> There is probably some oprofile/perfmon event that could tell
> you which function dirties the cacheline.
> 

I'll see if I can work it out. Thanks.

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
