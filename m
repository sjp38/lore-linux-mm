Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f49.google.com (mail-la0-f49.google.com [209.85.215.49])
	by kanga.kvack.org (Postfix) with ESMTP id 955DF6B006C
	for <linux-mm@kvack.org>; Fri,  1 Aug 2014 21:12:09 -0400 (EDT)
Received: by mail-la0-f49.google.com with SMTP id hz20so3745923lab.22
        for <linux-mm@kvack.org>; Fri, 01 Aug 2014 18:12:08 -0700 (PDT)
Received: from mail-la0-x22a.google.com (mail-la0-x22a.google.com [2a00:1450:4010:c03::22a])
        by mx.google.com with ESMTPS id yq6si17668722lab.120.2014.08.01.18.12.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 01 Aug 2014 18:12:06 -0700 (PDT)
Received: by mail-la0-f42.google.com with SMTP id pv20so3851772lab.29
        for <linux-mm@kvack.org>; Fri, 01 Aug 2014 18:12:06 -0700 (PDT)
From: Max Filippov <jcmvbkbc@gmail.com>
Subject: [PATCH v4 0/2] mm/highmem: make kmap cache coloring aware
Date: Sat,  2 Aug 2014 05:11:37 +0400
Message-Id: <1406941899-19932-1-git-send-email-jcmvbkbc@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-xtensa@linux-xtensa.org
Cc: Chris Zankel <chris@zankel.net>, Marc Gauthier <marc@cadence.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-mips@linux-mips.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Leonid Yegoshin <Leonid.Yegoshin@imgtec.com>, Steven Hill <Steven.Hill@imgtec.com>, Max Filippov <jcmvbkbc@gmail.com>

Hi,

this series adds mapping color control to the generic kmap code, allowing
architectures with aliasing VIPT cache to use high memory. There's also
use example of this new interface by xtensa.

Changes since v3:
- drop #include <asm/highmem.h> from mm/highmem.c as it's done in
  linux/highmem.h;
- add 'User-visible effect' section to changelog.

Max Filippov (2):
  mm/highmem: make kmap cache coloring aware
  xtensa: support aliasing cache in kmap

 arch/xtensa/include/asm/highmem.h | 40 +++++++++++++++++-
 arch/xtensa/mm/highmem.c          | 18 ++++++++
 mm/highmem.c                      | 86 ++++++++++++++++++++++++++++++++++-----
 3 files changed, 131 insertions(+), 13 deletions(-)

-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
