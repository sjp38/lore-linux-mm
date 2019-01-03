Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 406D48E0002
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 09:22:34 -0500 (EST)
Received: by mail-lj1-f199.google.com with SMTP id v74-v6so9549489lje.6
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 06:22:34 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m10-v6sor30747424lje.8.2019.01.03.06.22.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 03 Jan 2019 06:22:32 -0800 (PST)
From: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
Subject: [RFC PATCH v4 0/3] test driver to analyse vmalloc allocator
Date: Thu,  3 Jan 2019 15:21:05 +0100
Message-Id: <20190103142108.20744-1-urezki@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Kees Cook <keescook@chromium.org>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, Shuah Khan <shuah@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>, Thomas Gleixner <tglx@linutronix.de>, "Uladzislau Rezki (Sony)" <urezki@gmail.com>

Hello.

This is v4. I think it is ready to go with, unless there are extra requests
or comments.

Changes in v4:
    - Since the test can take time, switch to wait_for_completion_timeout()
      with HZ sleep interval to prevent triggering of the trace about hung
      task;
    - Fix clean apply for v4.20 kernel.

Changes in v3:
    - Export __vmalloc_node_range() with _GPL-only prefix;
    - Add skip cases if the test can not be executed in current environment.
      That is kselftest framework requirement.

Changes in v2:
    - Code cleanup to make it more simple;
    - Now __vmalloc_node_range() is exported if CONFIG_TEST_VMALLOC_MODULE=m
    - Integrate vmalloc test suite into tools/testing/selftests/vm

I think it is ready to go with, unless there are more requests or comments.

Thank you in advance.

Uladzislau Rezki (Sony) (3):
  vmalloc: export __vmalloc_node_range for CONFIG_TEST_VMALLOC_MODULE
  vmalloc: add test driver to analyse vmalloc allocator
  selftests/vm: add script helper for CONFIG_TEST_VMALLOC_MODULE

 lib/Kconfig.debug                          |  12 +
 lib/Makefile                               |   1 +
 lib/test_vmalloc.c                         | 548 +++++++++++++++++++++++++++++
 mm/vmalloc.c                               |   9 +
 tools/testing/selftests/vm/run_vmtests     |  16 +
 tools/testing/selftests/vm/test_vmalloc.sh | 176 +++++++++
 6 files changed, 762 insertions(+)
 create mode 100644 lib/test_vmalloc.c
 create mode 100755 tools/testing/selftests/vm/test_vmalloc.sh

-- 
2.11.0
