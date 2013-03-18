Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id A5D5B6B0027
	for <linux-mm@kvack.org>; Mon, 18 Mar 2013 16:21:03 -0400 (EDT)
From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH V2 0/3] Drivers: hv: balloon
Date: Mon, 18 Mar 2013 13:51:13 -0700
Message-Id: <1363639873-1576-1-git-send-email-kys@microsoft.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com, andi@firstfloor.org, akpm@linux-foundation.org, linux-mm@kvack.org, kamezawa.hiroyuki@gmail.com, mhocko@suse.cz, hannes@cmpxchg.org, yinghan@google.com
Cc: "K. Y. Srinivasan" <kys@microsoft.com>

Support 2M page allocations when memory is ballooned out of the
guest. Hyper-V Dynamic Memory protocol is optimized around the ability
to move memory in 2M chunks.

I have also included a patch to properly notify the host of permanent
hot-add failures.

In this version of the patches, I have added some additional comments to the
code and the patch descriptions.

K. Y. Srinivasan (3):
  mm: Export split_page()
  Drivers: hv: balloon: Support 2M page allocations for ballooning
  Drivers: hv: Notify the host of permanent hot-add failures

 drivers/hv/hv_balloon.c |   51 +++++++++++++++++++++++++++++++++++++++++++---
 mm/page_alloc.c         |    1 +
 2 files changed, 48 insertions(+), 4 deletions(-)

-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
