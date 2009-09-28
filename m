Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 490476B005D
	for <linux-mm@kvack.org>; Mon, 28 Sep 2009 11:30:01 -0400 (EDT)
Received: by qw-out-1920.google.com with SMTP id 5so1400980qwc.44
        for <linux-mm@kvack.org>; Mon, 28 Sep 2009 04:30:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <Pine.LNX.4.64.0909281131460.14446@sister.anvils>
References: <1254128590-27826-1-git-send-email-shijie8@gmail.com>
	 <Pine.LNX.4.64.0909281131460.14446@sister.anvils>
Date: Mon, 28 Sep 2009 15:30:21 +0400
Message-ID: <8acda98c0909280430w2700826cu55f9629bafab066f@mail.gmail.com>
Subject: Re: [PATCH] rmap : tidy the code
From: Nikita Danilov <danilov@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Huang Shijie <shijie8@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

2009/9/28 Hugh Dickins <hugh.dickins@tiscali.co.uk>:
> On Mon, 28 Sep 2009, Huang Shijie wrote:
>
>> Introduce is_page_mapped_in_vma() to merge the vma_address() and
>> page_check_address().
>>
>> Make the rmap codes more simple.
>
> There is indeed a recurring pattern there; but personally, I prefer
> that recurring pattern, to introducing another multi-argument layer.
>
> I think it would make more sense to do the vma_address() inside (a
> differently named) page_check_address(); but that would still have
> to return the address, so I'll probably prefer what we have now.
>
> (And that seems to have been Nikita's preference when he introduced
> page_check_address(), to keep the vma_address() part of it separate.)
>

Indeed, I tried to minimize the number of parameters and to avoid
making "address" an output parameter. But on the other hand, there
were only 2 page_check_address() call-sites back then. Now there are 5
of them, so adding a parameter is more justifiable.

> Other opinions?

I agree that adding EFAULT check into page_check_address() is better.
The only call-site that does not call vma_address() before
page_check_address() is __xip_unmap() and it explicitly BUG_ON()s on
the same condition.

>
> Hugh
>

Nikita.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
