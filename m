Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 145906B00EA
	for <linux-mm@kvack.org>; Mon,  7 May 2012 07:38:13 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 00/10] (no)bootmem bits for 3.5
Date: Mon,  7 May 2012 13:37:42 +0200
Message-Id: <1336390672-14421-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Gavin Shan <shangw@linux.vnet.ibm.com>, David Miller <davem@davemloft.net>, Yinghai Lu <yinghai@kernel.org>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi,

here are some (no)bootmem fixes and cleanups for 3.5.  Most of it is
unifying allocation behaviour across bootmem and nobootmem when it
comes to respecting the specified allocation address goal and numa.

But also refactoring the codebases of the two bootmem APIs so that we
can think about sharing code between them again.

 include/linux/bootmem.h |    3 ---
 mm/bootmem.c            |  118 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-------------------------------------------------------
 mm/nobootmem.c          |  112 ++++++++++++++++++++++++++++++++++++++++++++++++++++------------------------------------------------------------
 mm/sparse.c             |   25 ++++++++++++-------------
 4 files changed, 127 insertions(+), 131 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
