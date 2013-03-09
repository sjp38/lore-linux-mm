Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 16B266B0005
	for <linux-mm@kvack.org>; Fri,  8 Mar 2013 21:00:44 -0500 (EST)
Received: by mail-da0-f43.google.com with SMTP id u36so251857dak.30
        for <linux-mm@kvack.org>; Fri, 08 Mar 2013 18:00:43 -0800 (PST)
Message-ID: <513A97C5.7020008@gmail.com>
Date: Sat, 09 Mar 2013 10:00:37 +0800
From: Will Huck <will.huckk@gmail.com>
MIME-Version: 1.0
Subject: Re: Swap defragging
References: <CAGDaZ_rvfrBVCKMuEdPcSod684xwbUf9Aj4nbas4_vcG3V9yfg@mail.gmail.com> <20130308023511.GD23767@cmpxchg.org>
In-Reply-To: <20130308023511.GD23767@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Raymond Jennings <shentino@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>

Hi Johannes,
On 03/08/2013 10:35 AM, Johannes Weiner wrote:
> On Thu, Mar 07, 2013 at 06:07:23PM -0800, Raymond Jennings wrote:
>> Just a two cent question, but is there any merit to having the kernel
>> defragment swap space?
> That is a good question.
>
> Swap does fragment quite a bit, and there are several reasons for
> that.

Are there any tools to test and monitor swap subsystem and page reclaim 
subsystem?

> We swap pages in our LRU list order, but this list is sorted by first
> access, not by access frequency (not quite that cookie cutter, but the
> ordering is certainly fairly coarse).  This means that the pages may
> already be in suboptimal order for swap in at the time of swap out.
>
> Once written to disk, the layout tends to stick.  One reason is that
> we actually try to not free swap slots unless there is a shortage of
> swap space to save future swap out IO (grep for vm_swap_full()).  The
> other reason is that if a page shared among multiple threads is
> swapped out, it can not be removed from swap until all threads have
> faulted the page back in because of page table entries still referring
> to the swap slot on disk.  In a multi-threaded application, this is
> rather unlikely.
>
> So even though the referencing order of the application might change,
> the disk layout won't.  But adjusting the disk layout speculatively
> increases disk IO, so it could be hard to prove that you came up with
> a net improvement.
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
