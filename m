Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 34EAA6B006E
	for <linux-mm@kvack.org>; Tue, 31 Mar 2015 05:03:08 -0400 (EDT)
Received: by pactp5 with SMTP id tp5so13706971pac.1
        for <linux-mm@kvack.org>; Tue, 31 Mar 2015 02:03:07 -0700 (PDT)
Received: from tyo200.gate.nec.co.jp (TYO200.gate.nec.co.jp. [210.143.35.50])
        by mx.google.com with ESMTPS id ii4si18514705pbb.98.2015.03.31.02.03.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 31 Mar 2015 02:03:04 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp ([10.7.69.201])
	by tyo200.gate.nec.co.jp (8.13.8/8.13.4) with ESMTP id t2V930Ve016992
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Tue, 31 Mar 2015 18:03:01 +0900 (JST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 0/3] hugetlb fixlet v3
Date: Tue, 31 Mar 2015 08:50:45 +0000
Message-ID: <1427791840-11247-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

This is the update of "active page flag for hugetlb" patch [*1].

The main change is patch 2/3, which fixes the race condition where concurre=
nt
call of isolate_huge_page() causes kernel panic.

Patch 1/3 just mentions and "fixes" a potential problem, no behavioral chan=
ge.
Patch 3/3 is a cleanup, reduces lines of code.

[*1] http://thread.gmane.org/gmane.linux.kernel/1889277/focus=3D1889380
---
Summary:

Naoya Horiguchi (3):
      mm: don't call __page_cache_release for hugetlb
      mm: hugetlb: introduce PageHugeActive flag
      mm: hugetlb: cleanup using PageHugeActive flag

 include/linux/hugetlb.h |  8 +++--
 mm/hugetlb.c            | 83 +++++++++++++++++++++++++--------------------=
----
 mm/memory-failure.c     | 14 +++++++--
 mm/memory_hotplug.c     |  2 +-
 mm/swap.c               | 10 +++++-
 5 files changed, 71 insertions(+), 46 deletions(-)=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
