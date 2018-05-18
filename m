Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id C7D136B056C
	for <linux-mm@kvack.org>; Fri, 18 May 2018 00:32:49 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id l85-v6so3988386pfb.18
        for <linux-mm@kvack.org>; Thu, 17 May 2018 21:32:49 -0700 (PDT)
Received: from ns.ascade.co.jp (ext-host0001.ascade.co.jp. [218.224.228.194])
        by mx.google.com with ESMTP id g34-v6si6581258pld.411.2018.05.17.21.32.48
        for <linux-mm@kvack.org>;
        Thu, 17 May 2018 21:32:48 -0700 (PDT)
Subject: [PATCH v2 2/7] hugetlb: support migrate charging for surplus
 hugepages
References: <e863529b-7ce5-4fbe-8cff-581b5789a5f9@ascade.co.jp>
From: TSUKADA Koutaro <tsukada@ascade.co.jp>
Message-ID: <48877585-85de-ad4b-6b35-8e6dd24a43c0@ascade.co.jp>
Date: Fri, 18 May 2018 13:32:41 +0900
MIME-Version: 1.0
In-Reply-To: <e863529b-7ce5-4fbe-8cff-581b5789a5f9@ascade.co.jp>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Jonathan Corbet <corbet@lwn.net>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, David Rientjes <rientjes@google.com>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Marc-Andre Lureau <marcandre.lureau@redhat.com>, Punit Agrawal <punit.agrawal@arm.com>, Dan Williams <dan.j.williams@intel.com>, Vlastimil Babka <vbabka@suse.cz>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, tsukada@ascade.co.jp

Surplus hugepages allocated for migration also charge to memory cgroup.

Signed-off-by: TSUKADA Koutaro <tsukada@ascade.co.jp>
---
 hugetlb.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 679c151f..2e7b543 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1687,6 +1687,8 @@ static struct page *alloc_migrate_huge_page(struct hstate *h, gfp_t gfp_mask,
 	if (!page)
 		return NULL;

+	surplus_hugepage_set_charge(h, page);
+
 	/*
 	 * We do not account these pages as surplus because they are only
 	 * temporary and will be released properly on the last reference

-- 
Tsukada
