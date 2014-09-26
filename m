Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f44.google.com (mail-qa0-f44.google.com [209.85.216.44])
	by kanga.kvack.org (Postfix) with ESMTP id 20A1D6B003B
	for <linux-mm@kvack.org>; Fri, 26 Sep 2014 17:18:53 -0400 (EDT)
Received: by mail-qa0-f44.google.com with SMTP id x12so6800263qac.31
        for <linux-mm@kvack.org>; Fri, 26 Sep 2014 14:18:52 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v111si7165100qge.87.2014.09.26.14.18.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Sep 2014 14:18:50 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 0/2] hugetlb minor improvements
Date: Fri, 26 Sep 2014 16:44:09 -0400
Message-Id: <1411764251-31910-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

This patchset does minor improvements and cleanups for mm/hugetlb.c.
It's based on mmotm-2014-09-25-16-28 and shows no regression in libhugetlbfs test.

Tree: git@github.com:Naoya-Horiguchi/linux.git
Branch: mmotm-2014-09-25-16-28/hugetlb_minor_improvements
---
Summary:

Naoya Horiguchi (2):
      mm/hugetlb: improve suboptimal migration/hwpoisoned entry check
      mm/hugetlb: cleanup and rename is_hugetlb_entry_(migration|hwpoisoned)()

 mm/hugetlb.c | 60 ++++++++++++++++++++++--------------------------------------
 1 file changed, 22 insertions(+), 38 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
