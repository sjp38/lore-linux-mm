Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id A38A06B005A
	for <linux-mm@kvack.org>; Mon, 20 Aug 2012 12:42:29 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 0/5] Memory policy corruption fixes V2
Date: Mon, 20 Aug 2012 17:36:29 +0100
Message-Id: <1345480594-27032-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Dave Jones <davej@redhat.com>, Christoph Lameter <cl@linux.com>, Ben Hutchings <ben@decadent.org.uk>, Andi Kleen <ak@linux.intel.com>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>

This is a rebase with some small changes to Kosaki's "mempolicy memory
corruption fixlet" series. I had expected that Kosaki would have revised
the series by now but it's been waiting a long time.

Changelog since V1
o Rebase to 3.6-rc2
o Editted some of the changelogs
o Converted sp->lock to sp->mutex to close a race in shared_policy_replace()
o Reworked the refcount imbalance fix slightly
o Do not call mpol_put in shmem_alloc_page.

I tested this with trinity with CONFIG_DEBUG_SLAB enabled and it passed. I
did not test LTP such as Josh reported a problem with or with a database that
used shared policies like Andi tested. The series is almost all Kosaki's
work of course. If he has a revised series that simply got delayed in
posting it should take precedence.

 include/linux/mempolicy.h |    2 +-
 mm/mempolicy.c            |  142 +++++++++++++++++++++++++++++----------------
 2 files changed, 93 insertions(+), 51 deletions(-)

-- 
1.7.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
