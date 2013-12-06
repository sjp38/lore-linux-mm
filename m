Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 015396B0038
	for <linux-mm@kvack.org>; Fri,  6 Dec 2013 03:50:54 -0500 (EST)
Received: by mail-pd0-f179.google.com with SMTP id r10so660315pdi.24
        for <linux-mm@kvack.org>; Fri, 06 Dec 2013 00:50:54 -0800 (PST)
Received: from LGEMRELSE6Q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id bc2si60602442pad.187.2013.12.06.00.50.52
        for <linux-mm@kvack.org>;
        Fri, 06 Dec 2013 00:50:53 -0800 (PST)
Date: Fri, 6 Dec 2013 17:53:31 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [QUESTION] balloon page isolation needs LRU lock?
Message-ID: <20131206085331.GA24706@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello, Rafael.

I looked at some compaction code and found that some oddity about
balloon compaction. In isolate_migratepages_range(), if we meet
!PageLRU(), we check whether this page is for balloon compaction.
In this case, code needs locked. Is the lock really needed? I can't find
any relationship between balloon compaction and LRU lock.

Second question is that in above case if we don't hold a lock, we
skip this page. I guess that if we meet balloon page repeatedly, there
is no change to run isolation. Am I missing?

Please let me know what I am missing.

Thanks in advance.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
