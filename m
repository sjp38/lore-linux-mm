Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id D92096B0036
	for <linux-mm@kvack.org>; Fri,  1 Aug 2014 07:51:15 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id eu11so5664509pac.18
        for <linux-mm@kvack.org>; Fri, 01 Aug 2014 04:51:15 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id pj9si9470010pac.234.2014.08.01.04.51.14
        for <linux-mm@kvack.org>;
        Fri, 01 Aug 2014 04:51:14 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 0/2] faultaround updates
Date: Fri,  1 Aug 2014 14:51:07 +0300
Message-Id: <1406893869-32739-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Andrey Ryabinin <a.ryabinin@samsung.com>, Sasha Levin <sasha.levin@oracle.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

One fix and one tweak for faultaround code.

As alternative, we could just drop debugfs interface and make
fault_around_bytes constant.

Kirill A. Shutemov (2):
  mm: close race between do_fault_around() and fault_around_bytes_set()
  mm: mark fault_around_bytes __read_mostly

 mm/memory.c | 24 +++++++++---------------
 1 file changed, 9 insertions(+), 15 deletions(-)

-- 
2.0.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
