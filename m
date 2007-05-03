Message-ID: <46392A3C.30606@yahoo.com.au>
Date: Thu, 03 May 2007 10:18:04 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: 2.6.22 -mm merge plans: mm-more-rmap-checking
References: <20070430162007.ad46e153.akpm@linux-foundation.org> <Pine.LNX.4.64.0705011458060.16979@blonde.wat.veritas.com> <4637EC95.2010501@yahoo.com.au> <Pine.LNX.4.64.0705021355390.16517@blonde.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.64.0705021355390.16517@blonde.wat.veritas.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> On Wed, 2 May 2007, Nick Piggin wrote:
> 
>>Yes, but IIRC I put that in because there was another check in
>>SLES9 that I actually couldn't put in, but used this one instead
>>because it also caught the bug we saw.
>>... 
>>This was actually a rare corruption that is also in 2.6.21, and
>>as few rmap callsites as we have, it was never noticed until the
>>SLES9 bug check was triggered.
> 
> 
> You are being very mysterious.  Please describe this bug (privately
> if you think it's exploitable), and let's work on the patch to fix it,
> rather than this "debug" patch.

It is exec-fix-remove_arg_zero.patch in Andrew's tree, it's exploitable
in that it leaks memory, but it could also release corrupted pagetables
into quicklists on those architectures that have them...

Anyway, it quite likely would have gone unfixed for several more years
if we didn't have the bug triggers in. Now you could argue that my
patch obviously fixes all bugs in there (but I wouldn't :)), and being
most complex of the few callsites, _now_ we can avoid the bug checks.
However I'd prefer to keep them at least under CONFIG_DEBUG_VM.


>>Hmm, I didn't notice the do_swap_page change, rather just derived
>>its safety by looking at the current state of the code (which I
>>guess must have been post-do_swap_page change)...
> 
> 
> Your addition of page_add_new_anon_rmap clarified the situation too.
> 
> 
>>Do you have a pointer to the patch, for my interest?
> 
> 
> The patch which changed do_swap_page?
> 
> commit c475a8ab625d567eacf5e30ec35d6d8704558062
> Author: Hugh Dickins <hugh@veritas.com>
> Date:   Tue Jun 21 17:15:12 2005 -0700
> [PATCH] can_share_swap_page: use page_mapcount


Yeah, this one, thanks. I'm just interested.


> Or my intended PG_swapcache to PAGE_MAPPING_SWAP patch,
> which does assume PageLocked in page_add_anon_rmap?
> Yes, I can send you its current unsplit state if you like
> (but have higher priorities before splitting and commenting
> it for posting).

I would like to see that too, but when you are ready :)

Thanks,
Nick

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
