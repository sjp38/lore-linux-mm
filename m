Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f178.google.com (mail-lb0-f178.google.com [209.85.217.178])
	by kanga.kvack.org (Postfix) with ESMTP id 319386B0035
	for <linux-mm@kvack.org>; Fri, 25 Jul 2014 15:44:15 -0400 (EDT)
Received: by mail-lb0-f178.google.com with SMTP id c11so3820579lbj.9
        for <linux-mm@kvack.org>; Fri, 25 Jul 2014 12:44:14 -0700 (PDT)
Received: from mail-la0-x22c.google.com (mail-la0-x22c.google.com [2a00:1450:4010:c03::22c])
        by mx.google.com with ESMTPS id xp7si7293423lac.79.2014.07.25.12.44.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 25 Jul 2014 12:44:13 -0700 (PDT)
Received: by mail-la0-f44.google.com with SMTP id e16so3499269lan.3
        for <linux-mm@kvack.org>; Fri, 25 Jul 2014 12:44:12 -0700 (PDT)
From: Max Filippov <jcmvbkbc@gmail.com>
Subject: [PATCH v3 0/2] mm/highmem: make kmap cache coloring aware
Date: Fri, 25 Jul 2014 23:43:45 +0400
Message-Id: <1406317427-10215-1-git-send-email-jcmvbkbc@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-xtensa@linux-xtensa.org
Cc: Chris Zankel <chris@zankel.net>, Marc Gauthier <marc@cadence.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-mips@linux-mips.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Leonid Yegoshin <Leonid.Yegoshin@imgtec.com>, Steven Hill <Steven.Hill@imgtec.com>, Max Filippov <jcmvbkbc@gmail.com>

Hi,

this series adds mapping color control to the generic kmap code, allowing
architectures with aliasing VIPT cache to use high memory. There's also
use example of this new interface by xtensa.

Max Filippov (2):
  mm/highmem: make kmap cache coloring aware
  xtensa: support aliasing cache in kmap

 arch/xtensa/include/asm/highmem.h | 40 +++++++++++++++++-
 arch/xtensa/mm/highmem.c          | 18 ++++++++
 mm/highmem.c                      | 89 ++++++++++++++++++++++++++++++++++-----
 3 files changed, 134 insertions(+), 13 deletions(-)

-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
