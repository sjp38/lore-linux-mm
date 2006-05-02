Message-ID: <44574E49.3030600@yahoo.com.au>
Date: Tue, 02 May 2006 22:19:21 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch 00/14] remap_file_pages protection support
References: <20060430172953.409399000@zion.home.lan> <4456D5ED.2040202@yahoo.com.au> <4456D85E.6020403@yahoo.com.au> <20060502112409.GA28159@elte.hu>
In-Reply-To: <20060502112409.GA28159@elte.hu>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: blaisorblade@yahoo.it, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Ingo Molnar wrote:

> originally i tested this feature with some minimal amount of RAM 
> simulated by UML 128MB or so. That's just 32 thousand pages, but still 
> the improvement was massive: context-switch times in UML were cut in 
> half or more. Process-creation times improved 10-fold. With this feature 
> included I accidentally (for the first time ever!) confused an UML shell 
> prompt with a real shell prompt. (before that UML was so slow [even in 
> "skas mode"] that you'd immediately notice it by the shell's behavior)

Cool, thanks for the numbers.

> 
> the 'have 1 vma instead of 32,000 vmas' thing is a really, really big 
> plus. It makes UML comparable to Xen, in rough terms of basic VM design.
> 
> Now imagine a somewhat larger setup - 16 GB RAM UML instance with 4 
> million vmas per UML process ... Frankly, without 
> sys_remap_file_pages_prot() the UML design is still somewhat of a toy.

Yes, I guess I imagined the common case might have been slightly better,
however with reasonable RAM utilisation, fragmentation means I wouldn't
be surprised if it does easily get close to that worst theoretical case.

My request for numbers was more about the Intel/glibc people than Paolo:
I do realise it is a problem for UML. I just like to see nice numbers :)

I think UML's really neat, so I'd love to see this get in. I don't see
any fundamental sticking point, given a few iterations, and some more
discussion.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
