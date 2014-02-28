Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id 402CD6B006E
	for <linux-mm@kvack.org>; Fri, 28 Feb 2014 17:19:20 -0500 (EST)
Received: by mail-pb0-f42.google.com with SMTP id rr13so1340398pbb.1
        for <linux-mm@kvack.org>; Fri, 28 Feb 2014 14:19:19 -0800 (PST)
Received: from mail-pd0-x230.google.com (mail-pd0-x230.google.com [2607:f8b0:400e:c02::230])
        by mx.google.com with ESMTPS id q5si3477817pbh.194.2014.02.28.14.19.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 28 Feb 2014 14:19:19 -0800 (PST)
Received: by mail-pd0-f176.google.com with SMTP id r10so1289861pdi.7
        for <linux-mm@kvack.org>; Fri, 28 Feb 2014 14:19:18 -0800 (PST)
From: Ning Qu <quning@google.com>
Subject: [PATCH 0/1] mm, shmem: map few pages around fault address if they are in page cache
Date: Fri, 28 Feb 2014 14:18:50 -0800
Message-Id: <1393625931-2858-1-git-send-email-quning@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Chinner <david@fromorbit.com>, Ning Qu <quning@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Ning Qu <quning@google.com>

This is a follow-up patch for "mm: map few pages around fault address if they are in page cache"

We use the generic filemap_map_pages as ->map_pages in shmem/tmpfs.

Please consider applying.

=========================================================================
Below is just some simple experiment numbers from this patch, let me know if
you would like more:

Tested on Xeon machine with 64GiB of RAM, using the current default fault
order 4.

Sequential access 8GiB file
			Baseline 	with-patch
1 thread
    minor fault		205		101	
    time, seconds	7.94		7.82

Random access 8GiB file
			Baseline 	with-patch
1 thread
    minor fault		724		623
    time, seconds	9.75		9.84


Ning Qu (1):
  mm: implement ->map_pages for shmem/tmpfs

 mm/shmem.c | 1 +
 1 file changed, 1 insertion(+)

-- 
1.9.0.279.gdc9e3eb

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
