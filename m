Subject: Re: [PATCH] struct page shrinkage
Message-ID: <OFC19C560E.A00F9111-ON85256B74.006633D4@pok.ibm.com>
From: "Bulent Abali" <abali@us.ibm.com>
Date: Wed, 6 Mar 2002 13:41:51 -0500
MIME-Version: 1.0
Content-type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>



>> Andrew,
>> I have an application which needs to know the total number of locked and
>> dirtied pages at any given time.  In which application locked-page
>> accounting is done?   I don't see it in base 2.5.5.   Are there any
patches
>> or such that you can give pointers to?
>
>This is in the ebulliently growing delayed-allocate and
>buffer_head-bypass patches at
>
> http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.6-pre2/
>
>The implementation you're looking for is in dalloc-10-core.patch:
>mm.h and mm/page_alloc.c

extern struct page_state {
             unsigned long nr_dirty;
             unsigned long nr_locked;
} ____cacheline_aligned page_states[NR_CPUS];

This is perfect.   Looks like, if a run summation over all the CPUs I will
get the total locked and dirty pages, provided mm.h macros are respected.
What is the outlook for inclusion of this patch in the main kernel?  Do you
plan to submit or have been included yet?
Bulent




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
