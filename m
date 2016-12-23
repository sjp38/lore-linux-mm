Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 125F128027E
	for <linux-mm@kvack.org>; Fri, 23 Dec 2016 12:16:42 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id b1so547019191pgc.5
        for <linux-mm@kvack.org>; Fri, 23 Dec 2016 09:16:42 -0800 (PST)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id j62si34632166pgc.184.2016.12.23.09.16.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Dec 2016 09:16:41 -0800 (PST)
Received: by mail-pf0-x243.google.com with SMTP id 127so4200869pfg.0
        for <linux-mm@kvack.org>; Fri, 23 Dec 2016 09:16:40 -0800 (PST)
Subject: [net/mm PATCH v2 0/3] Page fragment updates
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Fri, 23 Dec 2016 09:16:39 -0800
Message-ID: <20161223170756.14573.74139.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org, davem@davemloft.net, netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, jeffrey.t.kirsher@intel.com

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

v2: Fixed a comparison between a void* and 0 due to copy/paste from free_pages

I'm listing this as a patch for net or mm since I had originally submitted
it against mm as that was where the patches for the __page_frag functions
has previously resided.  However they are now also in net, and I wanted to
get this fixed before the merge window closed as I was hoping to make use
of these APIs in net-next and I already have about 20 patches that are
waiting on these patches to be accepted.

I tried to get in touch with Andrew about this fix but I haven't heard any
reply to the email I sent out on Tuesday.  The last comment I had from
Andrew against v1 was "Looks good to me.  I have it all queued for post-4.9
processing.", but I haven't received any notice they were applied.

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
