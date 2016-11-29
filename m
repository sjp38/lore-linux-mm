Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 773BB6B0038
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 13:23:11 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id q10so445615153pgq.7
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 10:23:11 -0800 (PST)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id 63si60917176pfm.160.2016.11.29.10.23.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Nov 2016 10:23:10 -0800 (PST)
Received: by mail-pg0-x244.google.com with SMTP id x23so17100688pgx.3
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 10:23:10 -0800 (PST)
Subject: [mm PATCH 0/3] Page fragment updates
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Tue, 29 Nov 2016 10:23:08 -0800
Message-ID: <20161129182010.13445.31256.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: netdev@vger.kernel.org, edumazet@google.com, davem@davemloft.net, jeffrey.t.kirsher@intel.com, linux-kernel@vger.kernel.org

This patch series takes care of a few cleanups for the page fragments API.

First we do some renames so that things are much more consistent.  First we
move the page_frag_ portion of the name to the front of the functions
names.  Secondly we split out the cache specific functions from the other
page fragment functions by adding the word "cache" to the name.

Second I did some minor clean-up on the function calls so that they are
more inline with the existing __free_pages calls in terms of how they
operate.

Finally I added a bit of documentation that will hopefully help to explain
some of this.  I plan to revisit this later as we get things more ironed
out in the near future with the changes planned for the DMA setup to
support eXpress Data Path.

---

Alexander Duyck (3):
      mm: Rename __alloc_page_frag to page_frag_alloc and __free_page_frag to page_frag_free
      mm: Rename __page_frag functions to __page_frag_cache, drop order from drain
      mm: Add documentation for page fragment APIs


 Documentation/vm/page_frags               |   42 +++++++++++++++++++++++++++++
 drivers/net/ethernet/intel/igb/igb_main.c |    6 ++--
 include/linux/gfp.h                       |    9 +++---
 include/linux/skbuff.h                    |    2 +
 mm/page_alloc.c                           |   33 +++++++++++++----------
 net/core/skbuff.c                         |    8 +++---
 6 files changed, 73 insertions(+), 27 deletions(-)
 create mode 100644 Documentation/vm/page_frags

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
