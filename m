Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id F142E6B0253
	for <linux-mm@kvack.org>; Tue,  3 Jan 2017 12:10:20 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id b1so1339420362pgc.5
        for <linux-mm@kvack.org>; Tue, 03 Jan 2017 09:10:20 -0800 (PST)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id k1si69638592pld.296.2017.01.03.09.10.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jan 2017 09:10:20 -0800 (PST)
Received: by mail-pf0-x242.google.com with SMTP id c4so25924720pfb.3
        for <linux-mm@kvack.org>; Tue, 03 Jan 2017 09:10:19 -0800 (PST)
Subject: [next PATCH v3 0/3] Page fragment updates
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Tue, 03 Jan 2017 09:10:18 -0800
Message-ID: <20170103170057.5144.17621.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

This patch series takes care of a few cleanups for the page fragments API.

First we do some renames so that things are much more consistent.  First we
move the page_frag_ portion of the name to the front of the functions
names.  Secondly we split out the cache specific functions from the other
page fragment functions by adding the word "cache" to the name.

Finally I added a bit of documentation that will hopefully help to explain
some of this.  I plan to revisit this later as we get things more ironed
out in the near future with the changes planned for the DMA setup to
support eXpress Data Path.

---

v2: Fixed a comparison between a void* and 0 due to copy/paste from free_pages
v3: Updated first rename patch so that it is just a rename and doesn't impact
    the actual functionality to avoid performance regression.

I'm submitting this to Intel Wired Lan and Jeff Kirsher's "next-queue" for
acceptance as I have a series of other patches for igb that are blocked by
by these patches since I had to rename the functionality fo draining extra
references.

This series was going to be accepted for mmotm back when it was v1, however
since then I found a few minor issues that needed to be fixed.

I am hoping to get an Acked-by from Andrew Morton for these patches and
then have them submitted to David Miller as he has said he will accept them
if I get the Acked-by.  In the meantime if these can be applied to
next-queue while waiting on that Acked-by then I can submit the other
patches for igb and ixgbe for testing.

Alexander Duyck (3):
      mm: Rename __alloc_page_frag to page_frag_alloc and __free_page_frag to page_frag_free
      mm: Rename __page_frag functions to __page_frag_cache, drop order from drain
      mm: Add documentation for page fragment APIs


 Documentation/vm/page_frags               |   42 +++++++++++++++++++++++++++++
 drivers/net/ethernet/intel/igb/igb_main.c |    6 ++--
 include/linux/gfp.h                       |    9 +++---
 include/linux/skbuff.h                    |    2 +
 mm/page_alloc.c                           |   23 ++++++++--------
 net/core/skbuff.c                         |    8 +++---
 6 files changed, 66 insertions(+), 24 deletions(-)
 create mode 100644 Documentation/vm/page_frags

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
