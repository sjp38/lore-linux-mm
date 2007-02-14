Message-ID: <45D266E3.4050905@yahoo.com.au>
Date: Wed, 14 Feb 2007 12:33:23 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch] build error: allnoconfig fails on mincore/swapper_space
References: <20070212145040.c3aea56e.randy.dunlap@oracle.com> <20070212150802.f240e94f.akpm@linux-foundation.org> <45D12715.4070408@yahoo.com.au> <20070213121217.0f4e9f3a.randy.dunlap@oracle.com> <Pine.LNX.4.64.0702132224280.3729@blonde.wat.veritas.com> <20070213144909.70943de2.randy.dunlap@oracle.com> <Pine.LNX.4.64.0702140009320.21315@blonde.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.64.0702140009320.21315@blonde.wat.veritas.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Randy Dunlap <randy.dunlap@oracle.com>, tony.luck@gmail.com, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> On Tue, 13 Feb 2007, Randy Dunlap wrote:
> 
>>From: Randy Dunlap <randy.dunlap@oracle.com>
>>
>>Don't check for pte swap entries when CONFIG_SWAP=n.
>>And save 'present' in the vec array.
>>
>>mm/built-in.o: In function `sys_mincore':
>>(.text+0xe584): undefined reference to `swapper_space'
>>
>>Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
> 
> 
> What you've done there is fine, Randy, thank you.

Can't you have migration without swap?

> But I just got out of bed to take another look, and indeed:
> what is it doing in the none_mapped !vma->vm_file case?
> passing back an uninitialized vector.

I must have completely forgotten about the vector :(

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
