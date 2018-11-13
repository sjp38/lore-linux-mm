Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 76C9C6B0269
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 10:16:44 -0500 (EST)
Received: by mail-lj1-f200.google.com with SMTP id f5-v6so3939020ljj.17
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 07:16:44 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h143sor2830493lfg.54.2018.11.13.07.16.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 13 Nov 2018 07:16:42 -0800 (PST)
From: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
Subject: [RFC PATCH 0/1] test driver to analyse vmalloc allocator
Date: Tue, 13 Nov 2018 16:16:28 +0100
Message-Id: <20181113151629.14826-1-urezki@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>, Kees Cook <keescook@chromium.org>, Shuah Khan <shuah@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: LKML <linux-kernel@vger.kernel.org>, Matthew Wilcox <willy@infradead.org>, Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>, Thomas Gleixner <tglx@linutronix.de>, "Uladzislau Rezki (Sony)" <urezki@gmail.com>

Hello.

As an outcome of https://lkml.org/lkml/2018/10/19/786 discussion there was
an interest in stress/performance test suite. It was developed to analyse
a vmalloc allocator from performance, stability point of view and compare
the new approach with current one.

I have explained in the commit message in detail how to use this test driver,
so please have look at: vmalloc: add test driver to analyse vmalloc allocator

I think it is pretty easy and handy to use. I am not sure if i need to create
kind of run.sh or vmalloc.sh in tools/testing/selftests/ to configure the test
module over misc device or so to apply different configurations and trigger
the test.

This driver uses one internal function that is not accessible from the kernel
module, thus as a workaround i use kallsyms_lookup_name("__vmalloc_node_range")
to find the symbol.

Also, i need to mention one thing here this test suite allowed me to identify
some issues in current design. So please refer to the link i pointed above.


Uladzislau Rezki (Sony) (1):
  vmalloc: add test driver to analyse vmalloc allocator

 lib/Kconfig.debug  |  12 ++
 lib/Makefile       |   1 +
 lib/test_vmalloc.c | 543 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 556 insertions(+)
 create mode 100644 lib/test_vmalloc.c

-- 
2.11.0
