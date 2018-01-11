Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id F3F366B0271
	for <linux-mm@kvack.org>; Thu, 11 Jan 2018 14:18:03 -0500 (EST)
Received: by mail-vk0-f71.google.com with SMTP id k20so1917596vki.11
        for <linux-mm@kvack.org>; Thu, 11 Jan 2018 11:18:03 -0800 (PST)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id q11si1351195uaf.410.2018.01.11.11.18.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jan 2018 11:18:02 -0800 (PST)
From: Igor Stoppa <igor.stoppa@huawei.com>
Subject: [RESEND PATCH v2 0/2] mm: genalloc - track beginning of allocations
Date: Thu, 11 Jan 2018 21:17:45 +0200
Message-ID: <20180111191747.2350-1-igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, labbott@redhat.com, jes@trained-monkey.org, ying.huang@intel.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, linux-security-module@vger.kernel.org, Igor Stoppa <igor.stoppa@huawei.com>

This is a partial resend:
- the primary functionality (PATCH 1/2) is unmodified
- while waiting for review, I added selftest capability for genalloc (2/2)


During the effort of introducing in the kernel an allocator for
protectable memory (pmalloc), it was noticed that genalloc can be
improved, to know how to separate the memory use by adjacent allocations

However, it seems that the functionality could have a value of its own.

It can:
- verify that the freeing of memory is consistent with previous allocations
- relieve the user of the API from tracking the size of each allocation
- enable use cases where generic code can free memory allocations received
  through a pointer (provided that the reference pool is known)

Details about the implementation are provided in the comment for the patch.

I mentioned this idea few months ago, as part of the pmalloc discussion,
but then I did not have time to follow-up immediately, as I had hoped.

This is an implementation of what I had in mind.
It seems to withstand several test cases i put together, in the form of
self-test, but it definitely would need thorough review.


I hope I have added as reviewer all the relevant people.
If I missed someone, please include them to the recipients.



Igor Stoppa (2):
  genalloc: track beginning of allocations
  genalloc: selftest

 include/linux/genalloc-selftest.h |  30 +++
 include/linux/genalloc.h          |   3 +-
 init/main.c                       |   2 +
 lib/Kconfig                       |  14 ++
 lib/Makefile                      |   1 +
 lib/genalloc-selftest.c           | 402 ++++++++++++++++++++++++++++++++++++
 lib/genalloc.c                    | 417 ++++++++++++++++++++++++++------------
 7 files changed, 738 insertions(+), 131 deletions(-)
 create mode 100644 include/linux/genalloc-selftest.h
 create mode 100644 lib/genalloc-selftest.c

-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
