Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id E156D6B009F
	for <linux-mm@kvack.org>; Thu, 16 Dec 2010 23:37:41 -0500 (EST)
Received: by iwn40 with SMTP id 40so327303iwn.14
        for <linux-mm@kvack.org>; Thu, 16 Dec 2010 20:37:40 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.00.1012161804280.4484@tigran.mtv.corp.google.com>
References: <E1PStc6-0006Cd-0Z@pomaz-ex.szeredi.hu>
	<AANLkTikXQmsgZ8Ea-GoQ4k2St6yCJj8Z3XthuBQ9u+EV@mail.gmail.com>
	<E1PTCV4-0007sR-SO@pomaz-ex.szeredi.hu>
	<20101216220457.GA3450@barrios-desktop>
	<alpine.LSU.2.00.1012161708260.3351@tigran.mtv.corp.google.com>
	<AANLkTinhkZKWkthN1R39+6nDbN0xZq-g7jP5-LVLxZ3E@mail.gmail.com>
	<alpine.LSU.2.00.1012161804280.4484@tigran.mtv.corp.google.com>
Date: Fri, 17 Dec 2010 13:37:39 +0900
Message-ID: <AANLkTin-JUMNvoTubuVawsJLi89rG84K6EG3EBuc5gsK@mail.gmail.com>
Subject: Re: [PATCH] mm: add replace_page_cache_page() function
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: Miklos Szeredi <miklos@szeredi.hu>, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Dec 17, 2010 at 11:10 AM, Hugh Dickins <hughd@google.com> wrote:
> On Fri, 17 Dec 2010, Minchan Kim wrote:
>> On Fri, Dec 17, 2010 at 10:21 AM, Hugh Dickins <hughd@google.com> wrote:
>> >
>> > I disagree with you there: I like the way Miklos made it symmetric,
>> > I like the way delete_from_swap_cache drops the swap cache reference,
>> > I dislike the way remove_from_page_cache does not - I did once try to
>> > change that, but did a bad job, messed up reiserfs or reiser4 I forget
>> > which, retreated in shame.
>>
>> I agree symmetric is good. I just said current fact which is that
>> remove_from_page_cache doesn't release ref.
>> So I thought we have to match current semantic to protect confusing.
>> Okay. I will not oppose current semantics.
>> Instead of it, please add it (ex, caller should hold the page
>> reference) in function description.
>>
>> I am happy to hear that you tried it.
>> Although it is hard, I think it's very valuable thing.
>> Could you give me hint to googling your effort and why it is failed?
>
> http://lkml.org/lkml/2004/10/24/140

Thanks.

Now we have only 3 callers of remove_from_page_cache in mmtom.

1. truncate_huge_page
2. shmem_writepage
3. truncate_complete_page
4. fuse_try_move_page

It seems all of caller hold the page reference so It's ok to change
the semantic of remove_from_page_cache.
Okay. I will do that.

>
> Hugh
>



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
