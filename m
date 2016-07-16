Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id C5C436B025E
	for <linux-mm@kvack.org>; Sat, 16 Jul 2016 10:46:24 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id c52so261239112qte.2
        for <linux-mm@kvack.org>; Sat, 16 Jul 2016 07:46:24 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n97si9756621qte.91.2016.07.16.07.46.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 16 Jul 2016 07:46:24 -0700 (PDT)
Date: Sat, 16 Jul 2016 10:46:17 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: 4.1.28 is broken due to "mm/swap.c: flush lru pvecs on compound page
 arrival"
Message-ID: <alpine.LRH.2.02.1607161037180.18821@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lukasz Odzioba <lukasz.odzioba@intel.com>, Sasha Levin <sasha.levin@oracle.com>
Cc: Michal Hocko <mhocko@suse.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Ming Li <mingli199x@qq.com>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi

The patch c5ad33184354260be6d05de57e46a5498692f6d6 on the kernel v4.1.28 
breaks the kernel. The kernel crashes when executing the boot scripts with 
"kernel panic: Out of memory and no killable processes...". The machine 
has 512MB ram and 1 core.

Note that the upstream kernel 4.7-rc4 with this patch works, but when the 
patch is backported to the 4.1 branch, it makes the system unbootable.

Mikulas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
