Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4BAEA8E005B
	for <linux-mm@kvack.org>; Mon, 31 Dec 2018 08:26:56 -0500 (EST)
Received: by mail-lf1-f69.google.com with SMTP id m19so2575279lfj.17
        for <linux-mm@kvack.org>; Mon, 31 Dec 2018 05:26:56 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c190sor12264011lfd.62.2018.12.31.05.26.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 31 Dec 2018 05:26:54 -0800 (PST)
From: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
Subject: [RFC v2 0/3] test driver to analyse vmalloc allocator
Date: Mon, 31 Dec 2018 14:26:37 +0100
Message-Id: <20181231132640.21898-1-urezki@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>, Kees Cook <keescook@chromium.org>, Shuah Khan <shuah@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: LKML <linux-kernel@vger.kernel.org>, Matthew Wilcox <willy@infradead.org>, Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>, Thomas Gleixner <tglx@linutronix.de>, "Uladzislau Rezki (Sony)" <urezki@gmail.com>

Hello.

The first RFC was here: https://lkml.org/lkml/2018/11/13/957
Please have a look there for detailed description and discussion.
Here i will just specify what has been done since last RFC:

Changes in v2:
    - Code cleanup to make it more simple;
    - Now __vmalloc_node_range() is exported if CONFIG_TEST_VMALLOC_MODULE=m
    - Integrate vmalloc test suite into tools/testing/selftests/vm

I hope this test suite is more or less ready to go with. Appreciate your
comments and feedback anyway, so please RFC v2.

Thanks.

Uladzislau Rezks (Sony) (3):
  vmalloc: export __vmalloc_node_range for CONFIG_TEST_VMALLOC_MODULE
  vmalloc: add test driver to analyse vmalloc allocator
  selftests/vm: add script helper for CONFIG_TEST_VMALLOC_MODULE

 lib/Kconfig.debug                          |  12 +
 lib/Makefile                               |   1 +
 lib/test_vmalloc.c                         | 543 +++++++++++++++++++++++++++++
 mm/vmalloc.c                               |   9 +
 tools/testing/selftests/vm/run_vmtests     |  11 +
 tools/testing/selftests/vm/test_vmalloc.sh | 173 +++++++++
 6 files changed, 749 insertions(+)
 create mode 100644 lib/test_vmalloc.c
 create mode 100755 tools/testing/selftests/vm/test_vmalloc.sh

-- 
2.11.0
