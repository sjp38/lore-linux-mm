Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 6CBE282F92
	for <linux-mm@kvack.org>; Fri,  2 Oct 2015 01:40:21 -0400 (EDT)
Received: by pablk4 with SMTP id lk4so96469017pab.3
        for <linux-mm@kvack.org>; Thu, 01 Oct 2015 22:40:21 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id pd6si708463pbc.104.2015.10.01.22.40.20
        for <linux-mm@kvack.org>;
        Thu, 01 Oct 2015 22:40:20 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 0/3] page-flags updates
Date: Fri,  2 Oct 2015 08:40:13 +0300
Message-Id: <1443764416-129688-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Few updates based on Andrew's feedback.

Kirill A. Shutemov (3):
  page-flags: do not corrupt caller 'page' in PF_NO_TAIL
  page-flags: add documentation for policies
  page-flags: hide PF_* validation check under separate config option

 include/linux/mmdebug.h    |  6 ++++++
 include/linux/page-flags.h | 30 +++++++++++++++++++++---------
 lib/Kconfig.debug          |  8 ++++++++
 3 files changed, 35 insertions(+), 9 deletions(-)

-- 
2.5.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
