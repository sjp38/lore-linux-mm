Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id D0A656B0032
	for <linux-mm@kvack.org>; Mon, 19 Aug 2013 23:57:17 -0400 (EDT)
Message-ID: <5212E8DF.5020209@asianux.com>
Date: Tue, 20 Aug 2013 11:56:15 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
Subject: [PATCH 0/3] mm: mempolicy: the failure processing about mpol_to_str()
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, kosaki.motohiro@jp.fujitsu.com, riel@redhat.com, hughd@google.com, xemul@parallels.com, Cyrill Gorcunov <gorcunov@openvz.org>, rientjes@google.com, Wanpeng Li <liwanp@linux.vnet.ibm.com>hughd@google.com
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

For the implementation (patch 1/3), need fill buffer as full as
possible when buffer space is not enough.

For the caller (patch 2/3, 3/3), need check the return value of
mpol_to_str().

Signed-off-by: Chen Gang <gang.chen@asianux.com>
---
 fs/proc/task_mmu.c |   16 ++++++++++++++--
 mm/mempolicy.c     |   14 ++++++++++----
 mm/shmem.c         |   15 ++++++++++++++-
 3 files changed, 38 insertions(+), 7 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
