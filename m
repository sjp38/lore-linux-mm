Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f49.google.com (mail-qa0-f49.google.com [209.85.216.49])
	by kanga.kvack.org (Postfix) with ESMTP id 8888F6B0031
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 01:25:49 -0400 (EDT)
Received: by mail-qa0-f49.google.com with SMTP id cm18so2008805qab.36
        for <linux-mm@kvack.org>; Sun, 01 Jun 2014 22:25:49 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id t6si16382225qag.120.2014.06.01.22.25.48
        for <linux-mm@kvack.org>;
        Sun, 01 Jun 2014 22:25:48 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [RFC][PATCH 0/3] mm: introduce fincore()
Date: Mon,  2 Jun 2014 01:24:56 -0400
Message-Id: <1401686699-9723-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20140521193336.5df90456.akpm@linux-foundation.org>
References: <20140521193336.5df90456.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Arnaldo Carvalho de Melo <acme@redhat.com>, Borislav Petkov <bp@alien8.de>, "Kirill A. Shutemov" <kirill@shutemov.name>, Johannes Weiner <hannes@cmpxchg.org>, Rusty Russell <rusty@rustcorp.com.au>, David Miller <davem@davemloft.net>, Andres Freund <andres@2ndquadrant.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Due to the previous discussion[1], I learned that you people have discussed
this system call a few times (but not conclusion) and it can solve my problem
about pagecache scanning (see[2] for my motivation.) So I try it now.

The main patch of this patchset is patch 2, and this is based on Johannes's
previous version[3], so I CCed people who joined that discussion. While there
might be controversies about the format of data copied from kernel to userspace,
I take the Kirill's suggestion[4] which uses a flag to choose the data format,
which is extensible and flexible (you can cut off some info if you don't need it.)

And I added simple tests at patch 3, and patch 2 passes all the tests.

Any comments are welcomed.

[1] http://marc.info/?l=linux-kernel&m=140072606903894&w=2
[2] http://marc.info/?l=linux-mm&m=140072522603776&w=2
[3] http://thread.gmane.org/gmane.linux.kernel/1439212/focus=1441919
[4] http://marc.info/?l=linux-kernel&m=140075509611532&w=2

Thanks,
Naoya Horiguchi
---
Summary:

Naoya Horiguchi (3):
      replace PAGECACHE_TAG_* definition with enumeration
      mm: introduce fincore()
      selftest: add test code for fincore()

 arch/x86/syscalls/syscall_64.tbl                   |   1 +
 include/linux/fs.h                                 |   9 +-
 include/linux/syscalls.h                           |   2 +
 mm/Makefile                                        |   2 +-
 mm/fincore.c                                       | 362 +++++++++++++++++++++
 tools/testing/selftests/Makefile                   |   1 +
 tools/testing/selftests/fincore/Makefile           |  31 ++
 .../selftests/fincore/create_hugetlbfs_file.c      |  49 +++
 tools/testing/selftests/fincore/fincore.c          | 153 +++++++++
 tools/testing/selftests/fincore/run_fincoretests   | 355 ++++++++++++++++++++
 10 files changed, 961 insertions(+), 4 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
