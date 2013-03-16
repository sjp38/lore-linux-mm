Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 0A0356B0005
	for <linux-mm@kvack.org>; Sat, 16 Mar 2013 17:11:27 -0400 (EDT)
From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH 0/2] Drivers: hv: balloon 
Date: Sat, 16 Mar 2013 14:41:28 -0700
Message-Id: <1363470088-24565-1-git-send-email-kys@microsoft.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com, andi@firstfloor.org, akpm@linux-foundation.org, linux-mm@kvack.org, kamezawa.hiroyuki@gmail.com, mhocko@suse.cz, hannes@cmpxchg.org, yinghan@google.com
Cc: "K. Y. Srinivasan" <kys@microsoft.com>

Support 2M page allocations when memory is ballooned out of the
guest. Hyper-V Dynamic Memory protocol is optimized around the ability
to move memory in 2M chunks.

K. Y. Srinivasan (2):
  mm: Export split_page()
  Drivers: hv: balloon: Support 2M page allocations for ballooning

 drivers/hv/hv_balloon.c |   18 ++++++++++++++++--
 mm/page_alloc.c         |    1 +
 2 files changed, 17 insertions(+), 2 deletions(-)

-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
