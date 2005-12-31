Message-ID: <43B63931.6000307@yahoo.com.au>
Date: Sat, 31 Dec 2005 18:54:25 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC] Event counters [1/3]: Basic counter functionality
References: <20051220235733.30925.55642.sendpatchset@schroedinger.engr.sgi.com> <20051231064615.GB11069@dmt.cnet>
In-Reply-To: <20051231064615.GB11069@dmt.cnet>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Christoph Lameter <clameter@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

Marcelo Tosatti wrote:

> 
> What about this addition to the documentation above, to make it a little more 
> verbose:
> 
> 	The possible race scenario is restricted to kernel preemption,
> 	and could happen as follows:
> 
> 	thread A				thread B
> a)	movl    xyz(%ebp), %eax			movl    xyz(%ebp), %eax
> b)	incl    %eax				incl    %eax
> c)	movl    %eax, xyz(%ebp)			movl    %eax, xyz(%ebp)
> 
> Thread A can be preempted in b), and thread B succesfully increments the
> counter, writing it back to memory. Now thread A resumes execution, with
> its stale copy of the counter, and overwrites the current counter.
> 
> Resulting in increments lost.
> 
> However that should be relatively rare condition.
> 

Hi Guys,

I've been waiting for some mm/ patches to clear from -mm before commenting
too much... however I see that this patch is actually against -mm itself,
with my __mod_page_state stuff in it... that makes the page state accounting
much lighter weight AND is not racy.

So I'm not exactly sure why such a patch as this is wanted now? Are there
any more xxx_page_state hotspots? (I admit to only looking at page faults,
page allocator, and page reclaim).

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
