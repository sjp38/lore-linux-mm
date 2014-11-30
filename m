Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 33C156B0069
	for <linux-mm@kvack.org>; Sun, 30 Nov 2014 18:54:43 -0500 (EST)
Received: by mail-pd0-f170.google.com with SMTP id fp1so9677104pdb.15
        for <linux-mm@kvack.org>; Sun, 30 Nov 2014 15:54:42 -0800 (PST)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id uh8si26253729pab.198.2014.11.30.15.54.40
        for <linux-mm@kvack.org>;
        Sun, 30 Nov 2014 15:54:41 -0800 (PST)
Message-ID: <547BAE3C.5020309@lge.com>
Date: Mon, 01 Dec 2014 08:54:36 +0900
From: Gioh Kim <gioh.kim@lge.com>
MIME-Version: 1.0
Subject: [Lsf-pc] [LSF/MM ATTEND] Improving CMA
References: <5473E146.7000503@codeaurora.org> <20141127061204.GA6850@js1304-P5Q-DELUXE> <20141128071327.GB11802@js1304-P5Q-DELUXE>
In-Reply-To: <20141128071327.GB11802@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>, Jan Kara <jack@suse.cz>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, zhuhui@xiaomi.com, minchan@kernel.org, SeongJae Park <sj38.park@gmail.com>, linux-mm@kvack.org, mgorman@suse.de, lsf-pc@lists.linux-foundation.org


I'm very sorry for causing noise.

I wanted to use CMA for 2 applications:
1. power saving: clear one ddr chip and turn off power
2. memory allocation for device: GPU and video and so on

At first I've tested CMA for power saving with 2 out-of-tree patches:
1. https://lkml.org/lkml/2012/8/31/313 : Laura's patch
2. https://lkml.org/lkml/2014/5/28/64 : Joonsoo's patch

I wanted to allocate the entire ddr chip, in contiguous physical address 0xXXXXXXXX ~ 0xXXXXXXXX
so that the allocation must not be failed.
But it often failed and I found superblocks of some filesystems pined pages for buffer-head.
Therefore I sumbitted a patch, https://lkml.org/lkml/2014/9/4/78.

With them, my platform could've worked for hours
but it still has free-page-counting problem and needs more heavy load test.

Allocation latency Minchan mentioned is not problem for my platform.
CMA allocation is not often and limited to only one drivers.

Allocation guarantee, Minchan menthined, is, my main concern.
I hope it is fixed partly with my patch (https://lkml.org/lkml/2014/9/4/78).

I have a plan to use CMA for massive product next year.
So I'd like to attend LSF/MM and discuss this topic.

Sorry for the wrong request again.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
