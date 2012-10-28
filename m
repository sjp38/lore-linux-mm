Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 2AB236B006C
	for <linux-mm@kvack.org>; Sun, 28 Oct 2012 15:15:08 -0400 (EDT)
Received: by mail-da0-f41.google.com with SMTP id i14so2254980dad.14
        for <linux-mm@kvack.org>; Sun, 28 Oct 2012 12:15:07 -0700 (PDT)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH 0/5] minor clean-up and optimize highmem related code
Date: Mon, 29 Oct 2012 04:12:51 +0900
Message-Id: <1351451576-2611-1-git-send-email-js1304@gmail.com>
In-Reply-To: <Yes>
References: <Yes>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>

This patchset clean-up and optimize highmem related code.

[1] is just clean-up and doesn't introduce any functional change.
[2-3] are for clean-up and optimization.
These eliminate an useless lock opearation and list management.
[4-5] is for optimization related to flush_all_zero_pkmaps().

Joonsoo Kim (5):
  mm, highmem: use PKMAP_NR() to calculate an index of pkmap
  mm, highmem: remove useless pool_lock
  mm, highmem: remove page_address_pool list
  mm, highmem: makes flush_all_zero_pkmaps() return index of last
    flushed entry
  mm, highmem: get virtual address of the page using PKMAP_ADDR()

 include/linux/highmem.h |    1 +
 mm/highmem.c            |  102 ++++++++++++++++++++---------------------------
 2 files changed, 45 insertions(+), 58 deletions(-)

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
