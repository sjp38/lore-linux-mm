Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id C0FC88E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 03:59:41 -0500 (EST)
Received: by mail-lj1-f199.google.com with SMTP id f22-v6so8685001lja.7
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 00:59:41 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 2-v6sor29391426lje.12.2019.01.02.00.59.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 02 Jan 2019 00:59:39 -0800 (PST)
From: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
Subject: [RFC v3 0/3] test driver to analyse vmalloc allocator
Date: Wed,  2 Jan 2019 09:59:21 +0100
Message-Id: <20190102085924.14145-1-urezki@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>, Kees Cook <keescook@chromium.org>, Shuah Khan <shuah@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: LKML <linux-kernel@vger.kernel.org>, Matthew Wilcox <willy@infradead.org>, Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>, Thomas Gleixner <tglx@linutronix.de>, "Uladzislau Rezki (Sony)" <urezki@gmail.com>

Hello.

This is v3.

The first RFC was here: https://lkml.org/lkml/2018/11/13/957
Please have a look there for detailed description and discussion.

Changes in v3:
    - Export __vmalloc_node_range() with _GPL-only prefix;
    - Add skip cases if the test can not be executed in current environment.
      That is kselftest framework requirement.

Changes in v2:
    - Code cleanup to make it more simple;
    - Now __vmalloc_node_range() is exported if CONFIG_TEST_VMALLOC_MODULE=m
    - Integrate vmalloc test suite into tools/testing/selftests/vm

Appreciate your comments and feedback, so please RFC v3.

Thank you.

Uladzislau Rezki (Sony) (3):
  vmalloc: export __vmalloc_node_range for CONFIG_TEST_VMALLOC_MODULE
  vmalloc: add test driver to analyse vmalloc allocator
  selftests/vm: add script helper for CONFIG_TEST_VMALLOC_MODULE

 lib/Kconfig.debug                          |  12 +
 lib/Makefile                               |   1 +
 lib/test_vmalloc.c                         | 543 +++++++++++++++++++++++++++++
 mm/vmalloc.c                               |   9 +
 tools/testing/selftests/vm/run_vmtests     |  16 +
 tools/testing/selftests/vm/test_vmalloc.sh | 176 ++++++++++
 6 files changed, 757 insertions(+)
 create mode 100644 lib/test_vmalloc.c
 create mode 100755 tools/testing/selftests/vm/test_vmalloc.sh

-- 
2.11.0
