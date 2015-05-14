Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f53.google.com (mail-oi0-f53.google.com [209.85.218.53])
	by kanga.kvack.org (Postfix) with ESMTP id 9DD3E6B0071
	for <linux-mm@kvack.org>; Thu, 14 May 2015 06:41:31 -0400 (EDT)
Received: by oign205 with SMTP id n205so52295357oig.2
        for <linux-mm@kvack.org>; Thu, 14 May 2015 03:41:31 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id h10si12464262obx.63.2015.05.14.03.41.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 14 May 2015 03:41:25 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v2 0/4] hwpoison fixes for v4.2
Date: Thu, 14 May 2015 10:39:12 +0000
Message-ID: <1431599951-32545-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>
Cc: Dean Nelson <dnelson@redhat.com>, Tony Luck <tony.luck@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

I updated the hwpoison fix patchset. Patch 2 has major changes and patch 1
has a trivial change. The other patches has no change. Please see also ver.=
1
(http://thread.gmane.org/gmane.linux.kernel.mm/132586) for this patchset's
general description.

Thanks,
Naoya Horiguchi
---
Tree: https://github.com/Naoya-Horiguchi/linux/tree/v4.1-rc3/hwpoison_for_v=
4.2.v2
---
Summary:

Naoya Horiguchi (4):
      mm/memory-failure: split thp earlier in memory error handling
      mm/memory-failure: introduce get_hwpoison_page() for consistent refco=
unt handling
      mm: soft-offline: don't free target page in successful page migration
      mm/memory-failure: me_huge_page() does nothing for thp

 include/linux/mm.h   |   1 +
 mm/hwpoison-inject.c |   4 +-
 mm/memory-failure.c  | 163 +++++++++++++++++++++++------------------------=
----
 mm/migrate.c         |   9 ++-
 4 files changed, 82 insertions(+), 95 deletions(-)=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
