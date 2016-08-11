Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4DF216B025E
	for <linux-mm@kvack.org>; Thu, 11 Aug 2016 01:43:04 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 63so119000843pfx.0
        for <linux-mm@kvack.org>; Wed, 10 Aug 2016 22:43:04 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id f9si1425794pfa.18.2016.08.10.22.43.03
        for <linux-mm@kvack.org>;
        Wed, 10 Aug 2016 22:43:03 -0700 (PDT)
Date: Thu, 11 Aug 2016 13:41:36 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: drivers/rapidio/rio_cm.c:1849:7-14: WARNING opportunity for
 memdup_user
Message-ID: <201608111329.drQ86SBC%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexandre Bounine <alexandre.bounine@idt.com>
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
head:   85e97be32c6242c98dbbc7a241b4a78c1b93327b
commit: b6e8d4aa1110306378af0f3472a6b85a1f039a16 rapidio: add RapidIO channelized messaging driver
date:   8 days ago


coccinelle warnings: (new ones prefixed by >>)

>> drivers/rapidio/rio_cm.c:1849:7-14: WARNING opportunity for memdup_user

Please review and possibly fold the followup patch.

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
