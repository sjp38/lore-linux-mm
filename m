Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3CFA06B039F
	for <linux-mm@kvack.org>; Tue, 13 Jun 2017 06:28:37 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id a70so68589382pge.8
        for <linux-mm@kvack.org>; Tue, 13 Jun 2017 03:28:37 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id f5si8973099pln.126.2017.06.13.03.28.36
        for <linux-mm@kvack.org>;
        Tue, 13 Jun 2017 03:28:36 -0700 (PDT)
From: Will Deacon <will.deacon@arm.com>
Subject: [PATCH v2 0/3] mm: huge pages: Misc fixes for issues found during fuzzing
Date: Tue, 13 Jun 2017 11:28:39 +0100
Message-Id: <1497349722-6731-1-git-send-email-will.deacon@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: mark.rutland@arm.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, Punit.Agrawal@arm.com, mgorman@suse.de, steve.capper@arm.com, vbabka@suse.cz, Will Deacon <will.deacon@arm.com>

Hi all,

This is v2 of the patches previously posted here:

   http://www.spinics.net/lists/linux-mm/msg128577.html

Changes since v1 include:

  * Use smp_mb() instead of smp_mb__before_atomic() before atomic_set()
  * Added acks and fixes tag

Feedback welcome,

Will

--->8

Mark Rutland (1):
  mm: numa: avoid waiting on freed migrated pages

Will Deacon (2):
  mm/page_ref: Ensure page_ref_unfreeze is ordered against prior
    accesses
  mm: migrate: Stabilise page count when migrating transparent hugepages

 include/linux/page_ref.h |  1 +
 mm/huge_memory.c         |  8 +++++++-
 mm/migrate.c             | 15 ++-------------
 3 files changed, 10 insertions(+), 14 deletions(-)

-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
