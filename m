Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 109F86B0292
	for <linux-mm@kvack.org>; Fri, 26 May 2017 00:06:25 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e8so253503433pfl.4
        for <linux-mm@kvack.org>; Thu, 25 May 2017 21:06:25 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id n34si30061239pld.268.2017.05.25.21.06.23
        for <linux-mm@kvack.org>;
        Thu, 25 May 2017 21:06:23 -0700 (PDT)
Date: Fri, 26 May 2017 13:06:22 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: add counters for different page fault types
Message-ID: <20170526040622.GB17837@bbox>
References: <20170524194126.18040-1-semenzato@chromium.org>
 <20170525001915.GA14999@bbox>
 <CAA25o9SH=LSeeRAfHfMK0JyPuDfzLMMOvyXz5RZJ5taa3hybhw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAA25o9SH=LSeeRAfHfMK0JyPuDfzLMMOvyXz5RZJ5taa3hybhw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luigi Semenzato <semenzato@chromium.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Douglas Anderson <dianders@google.com>, Dmitry Torokhov <dtor@google.com>, Sonny Rao <sonnyrao@google.com>

On Thu, May 25, 2017 at 08:54:09AM -0700, Luigi Semenzato wrote:
> Thank you Minchan, that's certainly simpler and I am annoyed that I
> didn't consider that :/
> 
> By a quick look, there are a few differences but maybe they don't matter?
> 
> 1. can a major (anon) fault result in a hit in the swap cache?  So
> pswpin will not get incremented and the fault will be counted as a
> file fault.

If it is swap cache hit, it's not a major fault which causes IO
so VM count it as minor fault, not major.

> 
> 2. pswpin also counts swapins from readahead --- which however I think
> we have turned off (at least I hope so, since readahead isn't useful
> with zram, in fact maybe zram should log a warning when readahead is
> greater than 0 because I think that's the default).

Yub, I expected you guys used zram with readahead off so it shouldn't
be a big problem.
About auto resetting readahead with zram, I agree with you.
But there are some reasons I postpone the work. No want to discuss
it in this thread/moment. ;)

> 
> Incidentally, I understand anon and file faults, but what's a shmem fault?

For me, it was out of my interest but if you want to count shmem fault,
maybe, we need to introdue new stat(e.g., PSWPIN_SHM) in shmem_swapin
but there are concrete reasons to justify in changelog. :)

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
