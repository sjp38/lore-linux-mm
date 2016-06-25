Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2902A6B0005
	for <linux-mm@kvack.org>; Sat, 25 Jun 2016 13:41:41 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e189so307878305pfa.2
        for <linux-mm@kvack.org>; Sat, 25 Jun 2016 10:41:41 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id r85si14887451pfb.223.2016.06.25.10.41.40
        for <linux-mm@kvack.org>;
        Sat, 25 Jun 2016 10:41:40 -0700 (PDT)
Subject: [PATCH 0/2] ZONE_DEVICE cleanups
From: Dan Williams <dan.j.williams@intel.com>
Date: Sat, 25 Jun 2016 10:40:57 -0700
Message-ID: <146687645727.39261.14620086569655191314.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Eric Sandeen <sandeen@redhat.com>, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Jeff Moyer <jmoyer@redhat.com>, Vlastimil Babka <vbabka@suse.cz>

Minor cleanups for CONFIG_ZONE_DEVICE.

Andrew, killing the CONFIG_EXPERT dependency might be worth applying for
4.7, but otherwise these can wait for 4.8. These have received a "build
success" notification from the kbuild robot over 58 configs.  Please
apply, or ack and I'll queue them with the rest of the libnvdimm-for-4.8
updates.

---

Dan Williams (2):
      mm: CONFIG_ZONE_DEVICE stop depending on CONFIG_EXPERT
      mm: cleanup ifdef guards for vmem_altmap


 include/linux/memremap.h |    2 +-
 kernel/memremap.c        |    8 --------
 mm/Kconfig               |    2 +-
 3 files changed, 2 insertions(+), 10 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
