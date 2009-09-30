Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 6D5AF6B005A
	for <linux-mm@kvack.org>; Tue, 29 Sep 2009 23:10:39 -0400 (EDT)
Received: by ywh28 with SMTP id 28so8173018ywh.11
        for <linux-mm@kvack.org>; Tue, 29 Sep 2009 20:23:55 -0700 (PDT)
Message-ID: <4AC2CF46.5070600@gmail.com>
Date: Wed, 30 Sep 2009 11:23:50 +0800
From: Huang Shijie <shijie8@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] filemap : fix the wrong offset
References: <1254215185-29841-1-git-send-email-shijie8@gmail.com> <Pine.LNX.4.64.0909291129430.19216@sister.anvils>
In-Reply-To: <Pine.LNX.4.64.0909291129430.19216@sister.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> I really think this issue is better ignored.  There was a time,
> seven years ago, when I cared about it, and made such corrections
> in mm/shmem.c.  But we're chipping away at the tip of the iceberg
> here, and it's just a waste of everybody's time for so long as
> PAGE_CACHE_SIZE == PAGE_SIZE.
>
> There have been patches experimenting with PAGE_CACHE_SIZE multiple
> of PAGE_SIZE (and probably not PAGE_SIZE multiple of PAGE_CACHE_SIZE);
> and I've come to the conclusion that the only sensible place for these
> PAGE_CACHE_SHIFT - PAGE_SHIFT patches is in a patch which really makes
> that difference.
>
> I wish PAGE_CACHE_SIZE had never been added in the first place,
> long before it was needed; but ripping it out doesn't seem quite
> the right thing to do either; and likewise I leave a smattering of
> PAGE_CACHE_SHIFT - PAGE_SHIFT lines in, just to remind us from time
> to time that there might one day be a difference.
>
>   
Ok. I get it.

But the filemap_fault()  looks  strange. Some functions such as 
do_sync_mmap_readahead() treat offset
in the PAGE_CAHE_SHIFT unit,though offset is actually in the PAGE_SHIFT 
unit.
> I know this is a very unsatisfying response: but you and I
> and everyone else have better things to spend our time on.
> Thinking about the difference between two things that are
> always the same is rather a waste of mental energy.
>   
Thanks a lot for your explanation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
