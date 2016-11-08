Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C8EFE6B0038
	for <linux-mm@kvack.org>; Mon,  7 Nov 2016 20:42:18 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id y68so59808490pfb.6
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 17:42:18 -0800 (PST)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id h125si33960642pfb.24.2016.11.07.17.42.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 07 Nov 2016 17:42:18 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH] mm: fix unused variable warning
Date: Tue, 8 Nov 2016 01:41:08 +0000
Message-ID: <20161108014107.GA21079@hori1.linux.bs1.fc.nec.co.jp>
References: <1478561517-4317-13-git-send-email-n-horiguchi@ah.jp.nec.com>
 <201611080850.MhSq3cNm%fengguang.wu@intel.com>
 <20161108013602.GA20317@hori1.linux.bs1.fc.nec.co.jp>
In-Reply-To: <20161108013602.GA20317@hori1.linux.bs1.fc.nec.co.jp>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <EB4672CF0682DE4581E8DA34C885462A@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: "kbuild-all@01.org" <kbuild-all@01.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Pavel Emelyanov <xemul@parallels.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Balbir Singh <bsingharora@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

Fix the following warning:

  mm/memory_hotplug.c: In function 'try_offline_node':
  mm/memory_hotplug.c:2131:6: warning: unused variable 'i' [-Wunused-variab=
le]
    int i;
        ^

Reported-by: kbuild test robot <lkp@intel.com>
Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/memory_hotplug.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 534348ddd285..d612a75ceec4 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -2128,7 +2128,6 @@ void try_offline_node(int nid)
 	unsigned long start_pfn =3D pgdat->node_start_pfn;
 	unsigned long end_pfn =3D start_pfn + pgdat->node_spanned_pages;
 	unsigned long pfn;
-	int i;
=20
 	for (pfn =3D start_pfn; pfn < end_pfn; pfn +=3D PAGES_PER_SECTION) {
 		unsigned long section_nr =3D pfn_to_section_nr(pfn);
--=20
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
