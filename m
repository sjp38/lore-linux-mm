Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 47A9C6B0062
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 12:59:08 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa10so1223572pad.14
        for <linux-mm@kvack.org>; Wed, 31 Oct 2012 09:59:07 -0700 (PDT)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH v2 0/5] minor clean-up and optimize highmem related code
Date: Thu,  1 Nov 2012 01:56:32 +0900
Message-Id: <1351702597-10795-1-git-send-email-js1304@gmail.com>
In-Reply-To: <Yes>
References: <Yes>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>

This patchset clean-up and optimize highmem related code.

Change from v1
Rebase on v3.7-rc3
[4] Instead of returning index of last flushed entry, return first index.
And update last_pkmap_nr to this index to optimize more.

Summary for v1
[1] is just clean-up and doesn't introduce any functional change.
[2-3] are for clean-up and optimization.
These eliminate an useless lock opearation and list management.
[4-5] is for optimization related to flush_all_zero_pkmaps().

Joonsoo Kim (5):
  mm, highmem: use PKMAP_NR() to calculate an index of pkmap
  mm, highmem: remove useless pool_lock
  mm, highmem: remove page_address_pool list
  mm, highmem: makes flush_all_zero_pkmaps() return index of first
    flushed entry
  mm, highmem: get virtual address of the page using PKMAP_ADDR()

 include/linux/highmem.h |    1 +
 mm/highmem.c            |  108 ++++++++++++++++++++++-------------------------
 2 files changed, 51 insertions(+), 58 deletions(-)

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
