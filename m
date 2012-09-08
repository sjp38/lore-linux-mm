Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id E49546B00B5
	for <linux-mm@kvack.org>; Sat,  8 Sep 2012 18:16:40 -0400 (EDT)
Received: by qcsd16 with SMTP id d16so512625qcs.14
        for <linux-mm@kvack.org>; Sat, 08 Sep 2012 15:16:40 -0700 (PDT)
MIME-Version: 1.0
Date: Sun, 9 Sep 2012 01:16:39 +0300
Message-ID: <CAPqfFkCGuoJhkyyAJzxPo0VQJR6t7h1pCacKUa6PDiwWW7j5EA@mail.gmail.com>
Subject: [RFC] Try pages allocation from higher to lower orders
From: David Cohen <dacohen@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Hi,

I work with embedded Linux, but new to linux MM community.
I need a way to improve performance when allocating a high number of
pages. Can't describe the exact scenario, but need to request more
than 20k pages on a time-sensitive task.
Requesting pages with order > 0 is faster than requesting a single
page 20k times if memory isn't fragmented. But in case memory is
fragmented, at some point order > 0 may not be available and page
allocation process go through more expensive path, which ends up being
slower than requesting 20k single pages. I'd like to have a way to
choose faster option depending on fragmentation scenario.
Is there currently a reliable solution for this case? Couldn't find one.
If the answer is really "no", what does it sound like to implement a
function e.g. alloc_pages_try_orders(mask, min_order, max_order). The
idea would be to try to get from free list (faster path only) page
with order <= max_order and > order_min (the higher is preferable) and
allow slow path only if min_order is the only option.

Thanks for your time,

David Cohen

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
