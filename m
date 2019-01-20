Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7EDA18E0002
	for <linux-mm@kvack.org>; Sun, 20 Jan 2019 03:12:44 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id x13so9285067wro.9
        for <linux-mm@kvack.org>; Sun, 20 Jan 2019 00:12:44 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n188sor29933708wmn.17.2019.01.20.00.12.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 20 Jan 2019 00:12:42 -0800 (PST)
From: Yang Fan <nullptr.cpp@gmail.com>
Subject: [PATCH 0/2] mm/mmap.c: Remove some redundancy in arch_get_unmapped_area_topdown()
Date: Sun, 20 Jan 2019 09:12:26 +0100
Message-Id: <cover.1547966629.git.nullptr.cpp@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, will.deacon@arm.com
Cc: Yang Fan <nullptr.cpp@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This patchset remove some redundancy in function 
arch_get_unmapped_area_topdown().

[PATCH 1/2] mm/mmap.c: Remove redundant variable 'addr' in 
arch_get_unmapped_area_topdown()
[PATCH 2/2] mm/mmap.c: Remove redundant const qualifier of the no-pointer 
parameters

Yang Fan (2):
  mm/mmap.c: Remove redundant variable 'addr' in
    arch_get_unmapped_area_topdown()
  mm/mmap.c: Remove redundant const qualifier of the no-pointer
    parameters

 mm/mmap.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

-- 
2.17.1
