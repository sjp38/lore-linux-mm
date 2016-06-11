Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id A96BA6B0005
	for <linux-mm@kvack.org>; Sat, 11 Jun 2016 15:16:15 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id h68so42947754lfh.2
        for <linux-mm@kvack.org>; Sat, 11 Jun 2016 12:16:15 -0700 (PDT)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id fy7si20973323wjb.103.2016.06.11.12.16.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 11 Jun 2016 12:16:14 -0700 (PDT)
Received: by mail-wm0-x244.google.com with SMTP id m124so5798530wme.3
        for <linux-mm@kvack.org>; Sat, 11 Jun 2016 12:16:14 -0700 (PDT)
From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Subject: [RFC PATCH 0/3] mm, thp: convert from optimistic to conservative
Date: Sat, 11 Jun 2016 22:15:58 +0300
Message-Id: <1465672561-29608-1-git-send-email-ebru.akagunduz@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: hughd@google.com, riel@redhat.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com, Ebru Akagunduz <ebru.akagunduz@gmail.com>

This patch series converts thp design from optimistic to conservative, 
creates a sysfs integer knob for conservative threshold and documents it.

Ebru Akagunduz (3):
  mm, thp: revert allocstall comparing
  mm, thp: convert from optimistic to conservative
  doc: add information about min_ptes_young

 Documentation/vm/transhuge.txt     |  7 ++++
 include/trace/events/huge_memory.h | 10 ++---
 mm/khugepaged.c                    | 81 ++++++++++++++++++++++----------------
 3 files changed, 59 insertions(+), 39 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
