Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2CC826B0008
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 06:56:55 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id l4-v6so383100wme.7
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 03:56:55 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l204-v6sor235101wma.26.2018.07.17.03.56.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 17 Jul 2018 03:56:54 -0700 (PDT)
From: osalvador@techadventures.net
Subject: [RFC PATCH 0/3] Cleanup for free_area_init_node / free_area_init_core
Date: Tue, 17 Jul 2018 12:56:19 +0200
Message-Id: <20180717105622.12410-1-osalvador@techadventures.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: pasha.tatashin@oracle.com, mhocko@suse.com, vbabka@suse.cz, akpm@linux-foundation.org, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

From: Oscar Salvador <osalvador@suse.de>

While trying to cleanup the memhotplug code, I found quite difficult to follow
free_area_init_node / free_area_init_core wrt which functions get called
from the memhotplug path.

This is en effort to try to refactor / cleanup those two functions a little bit,
to make them easier to read.

It compiles, but I did not test it.
I would like to get some feedback to see if it is worth or not. 

Signed-off-by: Oscar Salvador <osalvador@suse.de>

Oscar Salvador (3):
  mm: Make free_area_init_core more readable by moving the ifdefs
  mm: Refactor free_area_init_core
  mm: Make free_area_init_node call certain functions only when booting

 mm/page_alloc.c | 193 ++++++++++++++++++++++++++++++++++----------------------
 1 file changed, 116 insertions(+), 77 deletions(-)

-- 
2.13.6
