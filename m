Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id C4D256B0574
	for <linux-mm@kvack.org>; Fri, 18 May 2018 00:39:40 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id c187-v6so4023789pfa.20
        for <linux-mm@kvack.org>; Thu, 17 May 2018 21:39:40 -0700 (PDT)
Received: from ns.ascade.co.jp (ext-host0001.ascade.co.jp. [218.224.228.194])
        by mx.google.com with ESMTP id c10-v6si5234570pgn.231.2018.05.17.21.39.39
        for <linux-mm@kvack.org>;
        Thu, 17 May 2018 21:39:39 -0700 (PDT)
Subject: [PATCH v2 6/7] Documentation, hugetlb: describe about
 charge_surplus_hugepages,
References: <e863529b-7ce5-4fbe-8cff-581b5789a5f9@ascade.co.jp>
From: TSUKADA Koutaro <tsukada@ascade.co.jp>
Message-ID: <07466cce-ca82-9024-a04a-c17291e64f84@ascade.co.jp>
Date: Fri, 18 May 2018 13:39:21 +0900
MIME-Version: 1.0
In-Reply-To: <e863529b-7ce5-4fbe-8cff-581b5789a5f9@ascade.co.jp>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Jonathan Corbet <corbet@lwn.net>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, David Rientjes <rientjes@google.com>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Marc-Andre Lureau <marcandre.lureau@redhat.com>, Punit Agrawal <punit.agrawal@arm.com>, Dan Williams <dan.j.williams@intel.com>, Vlastimil Babka <vbabka@suse.cz>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, tsukada@ascade.co.jp

Add a description about charge_surplus_hugepages.

Signed-off-by: TSUKADA Koutaro <tsukada@ascade.co.jp>
---
 hugetlbpage.txt |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/Documentation/vm/hugetlbpage.txt b/Documentation/vm/hugetlbpage.txt
index faf077d..af8d112 100644
--- a/Documentation/vm/hugetlbpage.txt
+++ b/Documentation/vm/hugetlbpage.txt
@@ -129,6 +129,11 @@ number of "surplus" huge pages from the kernel's normal page pool, when the
 persistent huge page pool is exhausted. As these surplus huge pages become
 unused, they are freed back to the kernel's normal page pool.

+/proc/sys/vm/charge_surplus_hugepages indicates to charge "surplus" huge pages
+obteined from the normal page pool to memory cgroup. If true, the amount to be
+overcommitted is limited within memory usage allowed by the memory cgroup to
+which the task belongs. The default value is false.
+
 When increasing the huge page pool size via nr_hugepages, any existing surplus
 pages will first be promoted to persistent huge pages.  Then, additional
 huge pages will be allocated, if necessary and if possible, to fulfill
@@ -169,6 +174,7 @@ Inside each of these directories, the same set of files will exist:
 	free_hugepages
 	resv_hugepages
 	surplus_hugepages
+	charge_surplus_hugepages

 which function as described above for the default huge page-sized case.

-- 
Tsukada
