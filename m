Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 161776B0039
	for <linux-mm@kvack.org>; Tue, 29 Jul 2014 07:33:48 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id lf10so12274407pab.30
        for <linux-mm@kvack.org>; Tue, 29 Jul 2014 04:33:47 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [143.182.124.21])
        by mx.google.com with ESMTP id 1si10433897pdf.153.2014.07.29.04.33.46
        for <linux-mm@kvack.org>;
        Tue, 29 Jul 2014 04:33:46 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 0/2] faultaround updates
Date: Tue, 29 Jul 2014 14:33:27 +0300
Message-Id: <1406633609-17586-1-git-send-email-kirill.shutemov@linux.intel.com>
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

 mm/memory.c | 20 +++++++++++++-------
 1 file changed, 13 insertions(+), 7 deletions(-)

-- 
2.0.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
