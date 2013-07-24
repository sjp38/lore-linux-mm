Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id E9E0D6B0031
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 17:15:09 -0400 (EDT)
From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH 0/2] Drivers: hv: balloon: Online memory segments "in context" 
Date: Wed, 24 Jul 2013 14:29:15 -0700
Message-Id: <1374701355-30799-1-git-send-email-kys@microsoft.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com, andi@firstfloor.org, akpm@linux-foundation.org, linux-mm@kvack.org, kamezawa.hiroyuki@gmail.com, mhocko@suse.cz, hannes@cmpxchg.org, yinghan@google.com, dave@sr71.net
Cc: "K. Y. Srinivasan" <kys@microsoft.com>

The current code depends on user level code to bring online memory
segments that have been hot added. Change this code to online memory
in the same context that is hot adding the memory.

This patch set implements the necessary infrastructure for making
it possible to online memory segments from within a driver.

K. Y. Srinivasan (2):
  Drivers: base: memory: Export functionality for "in kernel" onlining
    of memory
  Drivers: hv: balloon: Online the hot-added memory "in context"

 drivers/base/memory.c   |   35 +++++++++++++++++++++++++++++++++++
 drivers/hv/hv_balloon.c |   20 +++-----------------
 include/linux/memory.h  |    5 +++++
 3 files changed, 43 insertions(+), 17 deletions(-)

-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
