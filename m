Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f171.google.com (mail-ie0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id 1299B6B0039
	for <linux-mm@kvack.org>; Sat, 23 Aug 2014 18:12:35 -0400 (EDT)
Received: by mail-ie0-f171.google.com with SMTP id at1so8147176iec.16
        for <linux-mm@kvack.org>; Sat, 23 Aug 2014 15:12:34 -0700 (PDT)
Received: from mail-ig0-x24a.google.com (mail-ig0-x24a.google.com [2607:f8b0:4001:c05::24a])
        by mx.google.com with ESMTPS id qc5si12494661icb.107.2014.08.23.15.12.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 23 Aug 2014 15:12:33 -0700 (PDT)
Received: by mail-ig0-f202.google.com with SMTP id r2so186739igi.5
        for <linux-mm@kvack.org>; Sat, 23 Aug 2014 15:12:33 -0700 (PDT)
From: Peter Feiner <pfeiner@google.com>
Subject: [PATCH v2 0/3] softdirty fix and write notification cleanup
Date: Sat, 23 Aug 2014 18:11:58 -0400
Message-Id: <1408831921-10168-1-git-send-email-pfeiner@google.com>
In-Reply-To: <1408571182-28750-1-git-send-email-pfeiner@google.com>
References: <1408571182-28750-1-git-send-email-pfeiner@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Peter Feiner <pfeiner@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Cyrill Gorcunov <gorcunov@openvz.org>, Pavel Emelyanov <xemul@parallels.com>, Jamie Liu <jamieliu@google.com>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>

Here's the new patch that uses Kirill's approach of setting write
notifications on the VMA. I also included write notification cleanups and
fixes per our discussion.

Peter Feiner (3):
  mm: softdirty: enable write notifications on VMAs after VM_SOFTDIRTY
    cleared
  mm: mprotect: preserve special page protection bits
  mm: mmap: cleanup code that preserves special vm_page_prot bits

 fs/proc/task_mmu.c | 17 ++++++++++++++++-
 include/linux/mm.h | 15 +++++++++++++++
 mm/mmap.c          | 26 +++++++++++---------------
 mm/mprotect.c      |  2 +-
 4 files changed, 43 insertions(+), 17 deletions(-)

-- 
2.1.0.rc2.206.gedb03e5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
