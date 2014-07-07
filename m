Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f177.google.com (mail-we0-f177.google.com [74.125.82.177])
	by kanga.kvack.org (Postfix) with ESMTP id BEFB66B0044
	for <linux-mm@kvack.org>; Mon,  7 Jul 2014 18:30:03 -0400 (EDT)
Received: by mail-we0-f177.google.com with SMTP id u56so5074083wes.22
        for <linux-mm@kvack.org>; Mon, 07 Jul 2014 15:30:03 -0700 (PDT)
Received: from one.firstfloor.org (one.firstfloor.org. [193.170.194.197])
        by mx.google.com with ESMTPS id n7si51407568wja.159.2014.07.07.15.30.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 07 Jul 2014 15:30:02 -0700 (PDT)
Date: Tue, 8 Jul 2014 00:30:01 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: fallout of 16K stacks
Message-ID: <20140707223001.GD18735@two.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org


Since the 16K stack change I noticed a number of problems with
my usual stress tests. They have a tendency to bomb out
because something cannot fork.

- AIM7 on a dual socket socket system now cannot reliably run 
>1000 parallel jobs.
- LTP stress + memhog stress in parallel to something else
usually doesn't survive the night.

Do we need to strengthen the memory allocator to try
harder for 16K?

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
