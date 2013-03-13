Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 2F1DE6B0006
	for <linux-mm@kvack.org>; Tue, 12 Mar 2013 21:31:36 -0400 (EDT)
Received: by mail-ob0-f170.google.com with SMTP id wc20so518714obb.29
        for <linux-mm@kvack.org>; Tue, 12 Mar 2013 18:31:35 -0700 (PDT)
Message-ID: <513FD6F2.5060804@gmail.com>
Date: Wed, 13 Mar 2013 09:31:30 +0800
From: Will Huck <will.huckk@gmail.com>
MIME-Version: 1.0
Subject: Re: Swap defragging
References: <CAGDaZ_rvfrBVCKMuEdPcSod684xwbUf9Aj4nbas4_vcG3V9yfg@mail.gmail.com> <20130308023511.GD23767@cmpxchg.org> <513A97C5.7020008@gmail.com> <20130312165247.GB1953@cmpxchg.org>
In-Reply-To: <20130312165247.GB1953@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Raymond Jennings <shentino@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>

Hi Johannes,
On 03/13/2013 12:52 AM, Johannes Weiner wrote:
> On Sat, Mar 09, 2013 at 10:00:37AM +0800, Will Huck wrote:
>> Hi Johannes,
>> On 03/08/2013 10:35 AM, Johannes Weiner wrote:
>>> On Thu, Mar 07, 2013 at 06:07:23PM -0800, Raymond Jennings wrote:
>>>> Just a two cent question, but is there any merit to having the kernel
>>>> defragment swap space?
>>> That is a good question.
>>>
>>> Swap does fragment quite a bit, and there are several reasons for
>>> that.
>> Are there any tools to test and monitor swap subsystem and page
>> reclaim subsystem?

pgscan_kswapd_dma 0
pgscan_kswapd_dma32 0
pgscan_kswapd_normal 0
pgscan_kswapd_movable 0
pgscan_direct_dma 0
pgscan_direct_dma32 0
pgscan_direct_normal 0
pgscan_direct_movable 0
pgscan_direct_throttle 0
zone_reclaim_failed 0
pginodesteal 0
slabs_scanned 328704

slab cache is scaned but file-backed/swap-backed pages are not scanned, why?

> seekwatcher is great to see the IO patterns.  Anything that uses
> anonymous memory can test swap: a java job, multiplying matrixes,
> kernel builds etc.  I mostly log /proc/vmstat by taking snapshots at a
> regular interval during the workload, then plot and visually correlate
> the swapin/swapout counters with the individual LRU sizes, page fault
> rate, what have you, to get a feeling for what it's doing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
