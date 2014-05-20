Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id A7FB66B0036
	for <linux-mm@kvack.org>; Tue, 20 May 2014 13:45:31 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id ld10so532205pab.31
        for <linux-mm@kvack.org>; Tue, 20 May 2014 10:45:31 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id bk7si25588139pad.135.2014.05.20.10.45.30
        for <linux-mm@kvack.org>;
        Tue, 20 May 2014 10:45:30 -0700 (PDT)
Message-Id: <cover.1400607328.git.tony.luck@intel.com>
From: Tony Luck <tony.luck@intel.com>
Date: Tue, 20 May 2014 10:35:28 -0700
Subject: [PATCH 0/2] Fix some machine check application recovery cases
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Andi Kleen <andi@firstfloor.org>, Borislav Petkov <bp@suse.de>, Chen Gong <gong.chen@linux.jf.intel.com>

Tesing recovery in mult-threaded applications showed a couple
of issues in our code.

Tony Luck (2):
  memory-failure: Send right signal code to correct thread
  memory-failure: Don't let collect_procs() skip over processes for
    MF_ACTION_REQUIRED

 mm/memory-failure.c | 25 ++++++++++++++-----------
 1 file changed, 14 insertions(+), 11 deletions(-)

-- 
1.8.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
