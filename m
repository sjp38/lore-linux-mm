Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id D720D6B0639
	for <linux-mm@kvack.org>; Thu, 10 May 2018 14:55:16 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id 35-v6so1652735pla.18
        for <linux-mm@kvack.org>; Thu, 10 May 2018 11:55:16 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id e12-v6si1194184pgn.155.2018.05.10.11.55.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 May 2018 11:55:14 -0700 (PDT)
From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Subject: [PATCH v3 0/2] mm: PAGE_KERNEL_* fallbacks
Date: Thu, 10 May 2018 11:55:05 -0700
Message-Id: <20180510185507.2439-1-mcgrof@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: arnd@arndb.de
Cc: gregkh@linuxfoundation.org, willy@infradead.org, geert@linux-m68k.org, linux-m68k@lists.linux-m68k.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Luis R. Rodriguez" <mcgrof@kernel.org>

This is the 3rd iteration for moving PAGE_KERNEL_* fallback
definitions into asm-generic headers. Greg asked for a Changelog
for patch iteration changes, its below.

All these patches have been tested by 0-day.

Questions, and specially flames are greatly appreciated.

v3:

Removed documentation effort to keep tabs on which architectures
currently don't defint the respective PAGE_* flags. Keeping tabs
on this is just not worth it.

Ran a spell checker on all patches :)

v2:

I added a patch for PAGE_KERNEL_EXEC as suggested by Matthew Wilcox.

v1:

I sent out a patch just for dealing witht he fallback mechanism for
PAGE_KERNEL_RO.

Luis R. Rodriguez (2):
  mm: provide a fallback for PAGE_KERNEL_RO for architectures
  mm: provide a fallback for PAGE_KERNEL_EXEC for architectures

 drivers/base/firmware_loader/fallback.c |  5 -----
 include/asm-generic/pgtable.h           | 18 ++++++++++++++++++
 mm/nommu.c                              |  4 ----
 mm/vmalloc.c                            |  4 ----
 4 files changed, 18 insertions(+), 13 deletions(-)

-- 
2.17.0
