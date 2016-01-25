Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com [209.85.214.174])
	by kanga.kvack.org (Postfix) with ESMTP id 1FCA36B0005
	for <linux-mm@kvack.org>; Sun, 24 Jan 2016 20:57:18 -0500 (EST)
Received: by mail-ob0-f174.google.com with SMTP id ba1so106226225obb.3
        for <linux-mm@kvack.org>; Sun, 24 Jan 2016 17:57:18 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id pv10si15089398obb.80.2016.01.24.17.57.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 24 Jan 2016 17:57:16 -0800 (PST)
Subject: [LSF/MM ATTEND] Huge Page Futures
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <56A580F8.4060301@oracle.com>
Date: Sun, 24 Jan 2016 17:57:12 -0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

In a search of the archives, it appears huge page support in one form or
another has been a discussion topic in almost every LSF/MM gathering. Based
on patches submitted this past year, huge pages is still an area of active
development.  And, it appears this level of activity will  continue in the
coming year.

I propose a "Huge Page Futures" session to discuss large works in progress
as well as work people are considering for 2016.  Areas of discussion would
minimally include:

- Krill Shutemov's THP new refcounting code and the push for huge page
  support in the page cache.

- Matt Wilcox's huge page support in DAX enabled filesystems, but perhaps
  more interesting is the desire for supporting PUD pages.  This seems to
  beg the question of supporting transparent PUD pages elsewhere.

- Other suggestions?

My interest in attending also revolves around huge pages.  This past year
I have added functionality to hugetlbfs.  hugetlbfs is not dead, and is
very much in use by some DB implementations.  Proposed future work I will
be attempting includes:
- Adding userfaultfd support to hugetlbfs
- Adding shared page table (PMD) support to DAX much like that which exists
  for hugetlbfs

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
