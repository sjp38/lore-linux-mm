Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id E534D6B0298
	for <linux-mm@kvack.org>; Tue,  2 Jan 2018 05:03:24 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id z3so30141053pln.6
        for <linux-mm@kvack.org>; Tue, 02 Jan 2018 02:03:24 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t8sor15340584plz.136.2018.01.02.02.03.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Jan 2018 02:03:23 -0800 (PST)
From: Joey Pabalinas <joeypabalinas@gmail.com>
Subject: [PATCH 0/2] mm/zswap: add minor const/conditional optimizations
Date: Tue,  2 Jan 2018 00:03:18 -1000
Message-Id: <20180102100320.24801-1-joeypabalinas@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: sjenning@redhat.com, ddstreet@ieee.org, linux-kernel@vger.kernel.org, Joey Pabalinas <joeypabalinas@gmail.com>

Make a couple minor short-circuiting order and const changes
  - Since the pointed-to objects are never modified through
    these pointers, const-qualify type and compressor
    variables.
  - Test boolean before calling `strcmp()` to take
    advantage of short-circuiting.

Joey Pabalinas (2):
  mm/zswap: make type and compressor const
  mm/zswap: move `zswap_has_pool` to front of `if ()`

 mm/zswap.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
