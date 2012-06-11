Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id AE8846B0062
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 05:17:59 -0400 (EDT)
Received: by yenm7 with SMTP id m7so3017133yen.14
        for <linux-mm@kvack.org>; Mon, 11 Jun 2012 02:17:58 -0700 (PDT)
From: kosaki.motohiro@gmail.com
Subject: [PATCH 0/6][resend] mempolicy memory corruption fixlet
Date: Mon, 11 Jun 2012 05:17:24 -0400
Message-Id: <1339406250-10169-1-git-send-email-kosaki.motohiro@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Andrew Morton <akpm@google.com>, Dave Jones <davej@redhat.com>, Mel Gorman <mgorman@suse.de>, Christoph Lameter <cl@linux.com>, stable@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Hi

This is trivial fixes of mempolicy meory corruption issues. There
are independent patches each ather. and, they don't change userland
ABIs.

Thanks.

changes from v1: fix some typo of changelogs.

-----------------------------------------------
KOSAKI Motohiro (6):
  Revert "mm: mempolicy: Let vma_merge and vma_split handle
    vma->vm_policy linkages"
  mempolicy: Kill all mempolicy sharing
  mempolicy: fix a race in shared_policy_replace()
  mempolicy: fix refcount leak in mpol_set_shared_policy()
  mempolicy: fix a memory corruption by refcount imbalance in
    alloc_pages_vma()
  MAINTAINERS: Added MEMPOLICY entry

 MAINTAINERS    |    7 +++
 mm/mempolicy.c |  151 ++++++++++++++++++++++++++++++++++++++++----------------
 mm/shmem.c     |    9 ++--
 3 files changed, 120 insertions(+), 47 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
