Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 49D7C28027E
	for <linux-mm@kvack.org>; Fri,  5 Jan 2018 15:42:44 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id k44so3181039wre.1
        for <linux-mm@kvack.org>; Fri, 05 Jan 2018 12:42:44 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id x8si4658692wrd.236.2018.01.05.12.42.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Jan 2018 12:42:42 -0800 (PST)
Date: Fri, 5 Jan 2018 12:42:39 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [mmotm:master 152/256] mm/migrate.c:1934:53: sparse: incorrect
 type in argument 2 (different argument counts)
Message-Id: <20180105124239.8d9c4e5631b8488807349f89@linux-foundation.org>
In-Reply-To: <201801051507.45CKDK0l%fengguang.wu@intel.com>
References: <201801051507.45CKDK0l%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Michal Hocko <mhocko@suse.com>, kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Mike Kravetz <mike.kravetz@oracle.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Linux Memory Management List <linux-mm@kvack.org>, Stephen Rothwell <sfr@canb.auug.org.au>

On Fri, 5 Jan 2018 15:29:12 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:

> Hi Michal,
> 
> First bad commit (maybe != root cause):
> 
> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   1ceb98996d2504dd4e0bcb5f4cb9009a18cd8aaa
> commit: 37870392dd6966328ed2fe49a247ab37d6fa7344 [152/256] mm, hugetlb: unify core page allocation accounting and initialization
> reproduce:
>         # apt-get install sparse
>         git checkout 37870392dd6966328ed2fe49a247ab37d6fa7344
>         make ARCH=x86_64 allmodconfig
>         make C=1 CF=-D__CHECK_ENDIAN__
> 
> 

--- a/mm/migrate.c~mm-migrate-remove-reason-argument-from-new_page_t-fix-fix
+++ a/mm/migrate.c
@@ -1784,8 +1784,7 @@ static bool migrate_balanced_pgdat(struc
 }
 
 static struct page *alloc_misplaced_dst_page(struct page *page,
-					   unsigned long data,
-					   int **result)
+					   unsigned long data)
 {
 	int nid = (int) data;
 	struct page *newpage;
_

That's against mm-migrate-remove-reason-argument-from-new_page_t.patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
