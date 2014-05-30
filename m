Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 4A8936B0035
	for <linux-mm@kvack.org>; Fri, 30 May 2014 02:51:58 -0400 (EDT)
Received: by mail-wi0-f176.google.com with SMTP id n15so520733wiw.9
        for <linux-mm@kvack.org>; Thu, 29 May 2014 23:51:57 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id a1si2601460wix.8.2014.05.29.23.51.55
        for <linux-mm@kvack.org>;
        Thu, 29 May 2014 23:51:56 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 0/3] HWPOISON: improve memory error handling for multithread process
Date: Fri, 30 May 2014 02:51:07 -0400
Message-Id: <1401432670-24664-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <53877e9c.8b2cdc0a.1604.ffffea43SMTPIN_ADDED_BROKEN@mx.google.com>
References: <53877e9c.8b2cdc0a.1604.ffffea43SMTPIN_ADDED_BROKEN@mx.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tony Luck <tony.luck@intel.com>, Andi Kleen <andi@firstfloor.org>, Kamil Iskra <iskra@mcs.anl.gov>, Borislav Petkov <bp@suse.de>, Chen Gong <gong.chen@linux.jf.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This patchset is the summary of recent discussion about memory error handling
on multithread application. Patch 1 and 2 is for action required errors, and
patch 3 is for action optional errors.

This patchset is based on mmotm-2014-05-21-16-57.

Patches are also available on the following tree/branch.
  git@github.com:Naoya-Horiguchi/linux.git hwpoison/master

Thanks,
Naoya Horiguchi
---
Summary:

Naoya Horiguchi (1):
      mm/memory-failure.c: support dedicated thread to handle SIGBUS(BUS_MCEERR_AO)

Tony Luck (2):
      memory-failure: Send right signal code to correct thread
      memory-failure: Don't let collect_procs() skip over processes for MF_ACTION_REQUIRED

 Documentation/vm/hwpoison.txt |  5 +++
 mm/memory-failure.c           | 75 ++++++++++++++++++++++++++++++-------------
 2 files changed, 58 insertions(+), 22 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
