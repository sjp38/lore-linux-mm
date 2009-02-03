Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 497B56B004F
	for <linux-mm@kvack.org>; Tue,  3 Feb 2009 15:38:21 -0500 (EST)
Received: from zps38.corp.google.com (zps38.corp.google.com [172.25.146.38])
	by smtp-out.google.com with ESMTP id n13KcHs3026127
	for <linux-mm@kvack.org>; Tue, 3 Feb 2009 20:38:18 GMT
Received: from yx-out-2324.google.com (yxb8.prod.google.com [10.190.1.72])
	by zps38.corp.google.com with ESMTP id n13KcEO0019103
	for <linux-mm@kvack.org>; Tue, 3 Feb 2009 12:38:15 -0800
Received: by yx-out-2324.google.com with SMTP id 8so733123yxb.73
        for <linux-mm@kvack.org>; Tue, 03 Feb 2009 12:38:14 -0800 (PST)
MIME-Version: 1.0
Date: Tue, 3 Feb 2009 12:38:14 -0800
Message-ID: <77e5ae570902031238q5fc9231bpb65ecd511da5a9c7@mail.gmail.com>
Subject: Swap Memory
From: William Chan <williamchan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: wchan212@gmail.com
List-ID: <linux-mm.kvack.org>

Hi All,

According to my understanding of the kernel mm, swap pages are
allocated in order of priority.

For example, I have the follow swap devices: FlashDevice1 with
priority 1 and DiskDevice2 with priority 2 and DiskDevice3 with
priority3. FlashDevice1 will get filled up, then DsikDevice2 and
DiskDevice3.

To allocate a page of memroy in swap, the kernel will call
get_swap_page to find the first device with available swap slots and
then pass that device to scan_swap_map to allocate a page.

I see a "problem" with this: The kernel does not take advantage of
available bandwidth. For example: my system has 2 swap
devices...DiskDevice2 and DiskDevice3, they are both identical 20 GB
7200rpm drives. If we need 4 GB worth of swap pages, only DiskDevice2
will be filled up. We have available free bandwidth on DiskDevice3
that is never used. If we were to split the swap pages into the two
drives, 2 GB of swap on each drive - we can potentially double our
bandwidth (latency is another issue).

Another problem that I am working on is what if one device is Flash
and the second device is Rotational. Does the kernel mm employ a
scheme to evict LRU pages in Priority1 swap to Priority2 swap?



Regards,
will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
