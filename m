Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f177.google.com (mail-lb0-f177.google.com [209.85.217.177])
	by kanga.kvack.org (Postfix) with ESMTP id 5DC086B0032
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 16:00:19 -0400 (EDT)
Received: by lbbqq2 with SMTP id qq2so16649768lbb.3
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 13:00:18 -0700 (PDT)
Received: from mail-la0-x243.google.com (mail-la0-x243.google.com. [2a00:1450:4010:c03::243])
        by mx.google.com with ESMTPS id t6si6641724lby.29.2015.06.09.13.00.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jun 2015 13:00:17 -0700 (PDT)
Received: by lamq1 with SMTP id q1so3235027lam.0
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 13:00:16 -0700 (PDT)
Subject: [PATCHSET v3 0/4] pagemap: make useable for non-privilege users
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Tue, 09 Jun 2015 23:00:13 +0300
Message-ID: <20150609195333.21971.58194.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-api@vger.kernel.org, Mark Williamson <mwilliamson@undo-software.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>

This patchset makes pagemap useable again in the safe way. It adds bit
'map-exlusive' which is set if page is mapped only here and restores
access for non-privileged users but hides pfn from them.

Last patch removes page-shift bits and completes migration to the new
pagemap format: flags soft-dirty and mmap-exlusive are available only
in the new format.

v3: check permissions in ->open

---

Konstantin Khlebnikov (4):
      pagemap: check permissions and capabilities at open time
      pagemap: add mmap-exclusive bit for marking pages mapped only here
      pagemap: hide physical addresses from non-privileged users
      pagemap: switch to the new format and do some cleanup


 Documentation/vm/pagemap.txt |    3 -
 fs/proc/task_mmu.c           |  219 +++++++++++++++++++-----------------------
 tools/vm/page-types.c        |   35 +++----
 3 files changed, 118 insertions(+), 139 deletions(-)

--
Signature

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
