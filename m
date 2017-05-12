Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id C10906B0038
	for <linux-mm@kvack.org>; Fri, 12 May 2017 01:53:31 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id i63so39694348pgd.15
        for <linux-mm@kvack.org>; Thu, 11 May 2017 22:53:31 -0700 (PDT)
Received: from mail-pg0-x22f.google.com (mail-pg0-x22f.google.com. [2607:f8b0:400e:c05::22f])
        by mx.google.com with ESMTPS id h62si2360372pge.75.2017.05.11.22.53.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 May 2017 22:53:31 -0700 (PDT)
Received: by mail-pg0-x22f.google.com with SMTP id u187so25258229pgb.0
        for <linux-mm@kvack.org>; Thu, 11 May 2017 22:53:30 -0700 (PDT)
Date: Fri, 12 May 2017 14:53:22 +0900
From: Joonsoo Kim <js1304@gmail.com>
Subject: mm/kasan: zero_p4d_populate() problem?
Message-ID: <20170512055320.GA16929@js1304-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kirill.shutemov@linux.intel.com
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, linux-mm@kvack.org

Hello, Kirill.

I found that zero_p4d_populate() in mm/kasan/kasan_init.c of
next-20170511 doesn't get the benefit of the kasan_zero_pud.
Do we need to fix it by adding
"pud_populate(&init_mm, pud, lm_alias(kasan_zero_pud));" when
alignment requirement is met?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
