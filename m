Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f197.google.com (mail-ob0-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4521F6B007E
	for <linux-mm@kvack.org>; Fri,  6 May 2016 07:38:55 -0400 (EDT)
Received: by mail-ob0-f197.google.com with SMTP id n2so226588874obo.1
        for <linux-mm@kvack.org>; Fri, 06 May 2016 04:38:55 -0700 (PDT)
Received: from g4t3427.houston.hp.com (g4t3427.houston.hp.com. [15.201.208.55])
        by mx.google.com with ESMTPS id mq8si7186505obb.54.2016.05.06.04.38.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 May 2016 04:38:54 -0700 (PDT)
Date: Fri, 6 May 2016 17:08:41 +0530
From: Kuthonuzo Luruo <kuthonuzo.luruo@hpe.com>
Subject: [PATCH v2 0/2] KASAN double-free detection
Message-ID: <20160506113841.GA23545@cherokee.in.rdlabs.hpecorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aryabinin@virtuozzo.com, glider@google.com, dvyukov@google.com, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org
Cc: kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kuthonuzo.luruo@hpe.com

First patch provides more reliable double-free detection for KASAN. Review
comments and suggestions from Dmitry Vyukov incorporated. Thanks, Dmitry!

Second patch provides a new concurrent double-free test for 'test_kasan'.

New patchset created from initial version "[PATCH] kasan: improve KASAN
double-free detection". v1 link: https://lkml.org/lkml/2016/5/2/147

SLAB maintainers added to "To:" because of change in mm/slab.c.

Kuthonuzo Luruo (2):
  mm, kasan: improve double-free detection
  kasan: add kasan_double_free() test

 include/linux/kasan.h |    8 +++
 lib/test_kasan.c      |   79 +++++++++++++++++++++++++++++++++
 mm/kasan/kasan.c      |  118 ++++++++++++++++++++++++++++++++++++-------------
 mm/kasan/kasan.h      |   15 +++++-
 mm/kasan/quarantine.c |    7 +++-
 mm/kasan/report.c     |   31 +++++++++++--
 mm/slab.c             |    1 +
 7 files changed, 221 insertions(+), 38 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
