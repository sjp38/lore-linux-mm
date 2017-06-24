Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3603C6B02B4
	for <linux-mm@kvack.org>; Sat, 24 Jun 2017 00:34:37 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id b9so61546591pgr.1
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 21:34:37 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id s3si4688907pgs.4.2017.06.23.21.34.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Jun 2017 21:34:36 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id d5so10117530pfe.1
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 21:34:36 -0700 (PDT)
From: john.hubbard@gmail.com
Subject: [PATCH 0/1] Remove unused variable from memory_hotplug.c
Date: Fri, 23 Jun 2017 21:34:20 -0700
Message-Id: <20170624043421.24465-1-jhubbard@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>

From: John Hubbard <jhubbard@nvidia.com>

Hi,

While poking around trying to understand Michal's
"[PATCH -v4 0/14] mm: make movable onlining suck less",
I noticed this minor thing, and the fix doesn't seem
to conflict with any of the ongoing patchsets I've
seen lately, so it seems harmless to just fix it.

This is patched against today's linux-next.

John Hubbard (1):
  mm: remove unused zone_type variable from __remove_zone()

 mm/memory_hotplug.c | 3 ---
 1 file changed, 3 deletions(-)

-- 
2.13.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
