Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 5BEC46B0071
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 11:17:58 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 0/3 v2] HWPOISON: improve dirty pagecache error reporting
Date: Wed, 22 Aug 2012 11:17:32 -0400
Message-Id: <1345648655-4497-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi.kleen@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Tony Luck <tony.luck@intel.com>, Rik van Riel <riel@redhat.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi,

Based on the previous discussion, in this version I propose only error
reporting fix ("overwrite recovery" is sparated out from this series.)

I think Fengguang's patch (patch 2 in this series) has a corner case
about inode cache drop, so I added patch 3 for it.

Shortlog and diffstat

 Naoya Horiguchi (2):
       HWPOISON: fix action_result() to print out dirty/clean
       HWPOISON: prevent inode cache removal to keep AS_HWPOISON sticky
 
 Wu Fengguang (1):
       HWPOISON: report sticky EIO for poisoned file
 
  fs/inode.c              | 12 ++++++++++++
  include/linux/pagemap.h | 24 ++++++++++++++++++++++++
  mm/filemap.c            | 11 +++++++++++
  mm/memory-failure.c     | 24 ++++++++++--------------
  mm/truncate.c           |  2 ++
  5 files changed, 59 insertions(+), 14 deletions(-)

Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
