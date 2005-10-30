Message-ID: <43644C22.8050501@yahoo.com.au>
Date: Sun, 30 Oct 2005 15:29:22 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: munmap extremely slow even with untouched mapping.
References: <20051028013738.GA19727@attica.americas.sgi.com> <43620138.6060707@yahoo.com.au> <Pine.LNX.4.61.0510281557440.3229@goblin.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.61.0510281557440.3229@goblin.wat.veritas.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Robin Holt <holt@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:

> Yes, it's a good observation from Robin.
> 
> It'll have been spoiling the exit speedup we expected from your
> 2.6.14 copy_page_range "Don't copy [faultable] ptes" fork speedup.
> 

Yep. Not to mention it is probably responsible for some of the
4 level page table performance slowdowns on x86-64.

> 
> 
> I prefer your patch too.  But I'm not very interested in temporary
> speedups relative to 2.6.14.  Attacking this is a job I'd put off
> until after the page fault scalability changes, which make it much
> easier to do a proper job.
> 

Yeah definitely.

I wonder if we should go with Robin's fix (+/- my variation)
as a temporary measure for 2.6.15?

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
