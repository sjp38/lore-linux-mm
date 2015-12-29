Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f181.google.com (mail-pf0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id BAF176B026C
	for <linux-mm@kvack.org>; Tue, 29 Dec 2015 15:47:32 -0500 (EST)
Received: by mail-pf0-f181.google.com with SMTP id e65so79316741pfe.1
        for <linux-mm@kvack.org>; Tue, 29 Dec 2015 12:47:32 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id zm10si8537586pac.26.2015.12.29.12.47.31
        for <linux-mm@kvack.org>;
        Tue, 29 Dec 2015 12:47:31 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 0/2] THP mlock fix
Date: Tue, 29 Dec 2015 23:46:28 +0300
Message-Id: <1451421990-32297-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sasha Levin <sasha.levin@oracle.com>, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Hi Andrew,

There are two patches below. I believe either of the would fix the bug
reported by Sasha, but it worth applying both.

Sasha, as I cannot trigger the bug, I would like to have your Tested-by.

Kirill A. Shutemov (2):
  mm, oom: skip mlocked VMAs in __oom_reap_vmas()
  mm, thp: clear PG_mlocked when last mapping gone

 mm/oom_kill.c | 7 +++++++
 mm/rmap.c     | 3 +++
 2 files changed, 10 insertions(+)

-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
