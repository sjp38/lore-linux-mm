Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 348476B0069
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 18:42:51 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id h7so2910128wjy.6
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 15:42:51 -0800 (PST)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id q66si2367968wma.126.2017.01.13.15.42.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jan 2017 15:42:49 -0800 (PST)
Received: by mail-wm0-x242.google.com with SMTP id c85so15068132wmi.1
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 15:42:49 -0800 (PST)
Date: Sat, 14 Jan 2017 02:42:47 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: [LSF/MM ATTEND] THP for ext4, page table manipulation primitives
Message-ID: <20170113234247.GD24312@node>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

Hello,

I would like to attend the summit this year.

===

One topic I would like to discuss would be huge pages for ext4 and
filesystems with backing storage in general. There's patchset that
I have hard time upstreaming. I hope having talk about this in person
would help moving it forward.

===

The other topic: the work on 5-level paging made more obvious that we need
better way to deal with page tables. Having different data-types per
page table level plus set of helpers to deal with each of them doesn't
scale. It worked okay of 2- and 3- level page tables. For 5-, it's getting
rather ugly.

And having different types/helpers to deal with different page table
levels makes it harder to integrate huge pages into generic code path:
having separate code path for each page size is not very future proof
approach.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
