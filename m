Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 580226B0259
	for <linux-mm@kvack.org>; Wed,  9 Sep 2015 00:09:34 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so147342697pac.2
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 21:09:34 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTP id q2si9194126pds.92.2015.09.08.21.09.30
        for <linux-mm@kvack.org>;
        Tue, 08 Sep 2015 21:09:33 -0700 (PDT)
From: Wang Long <long.wanglong@huawei.com>
Subject: [PATCH 0/2] KASAN: fix a type conversion error and add test
Date: Wed, 9 Sep 2015 03:59:38 +0000
Message-ID: <1441771180-206648-1-git-send-email-long.wanglong@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ryabinin.a.a@gmail.com, adech.fo@gmail.com
Cc: akpm@linux-foundation.org, rusty@rustcorp.com.au, long.wanglong@huawei.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, wanglong@laoqinren.net, peifeiyue@huawei.com, morgan.wang@huawei.com

Hi,

This patchset fix a type conversion error for KASAN.

patch 1: this patch add some out-of-bounds testcases, the current KASAN code
can not find these bugs.

patch 2: fix the type conversion error, with this patch, KASAN could find
these out-of-bounds bugs.

Wang Long (2):
  lib: test_kasan: add some testcases
  kasan: Fix a type conversion error

 lib/test_kasan.c | 69 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/kasan/kasan.c |  2 +-
 2 files changed, 70 insertions(+), 1 deletion(-)

-- 
1.8.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
