Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f177.google.com (mail-qk0-f177.google.com [209.85.220.177])
	by kanga.kvack.org (Postfix) with ESMTP id 36D2E6B007E
	for <linux-mm@kvack.org>; Fri,  4 Mar 2016 18:50:53 -0500 (EST)
Received: by mail-qk0-f177.google.com with SMTP id s5so27567416qkd.0
        for <linux-mm@kvack.org>; Fri, 04 Mar 2016 15:50:53 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g203si5796406qhg.1.2016.03.04.15.50.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Mar 2016 15:50:52 -0800 (PST)
From: Laura Abbott <labbott@fedoraproject.org>
Subject: [PATCHv4 0/2] Sanitization of buddy pages
Date: Fri,  4 Mar 2016 15:50:46 -0800
Message-Id: <1457135448-15541-1-git-send-email-labbott@fedoraproject.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Kees Cook <keescook@chromium.org>
Cc: Laura Abbott <labbott@fedoraproject.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

Hi,

This is v4 of the santization of buddy pages. This is mostly just a rebase
and some phrasing tweaks from v2. Kees submitted a rebase of v3 so this is v4.

Kees, I'm hoping you will give your Tested-by and provide some stats from the
tests you were running before.

Thanks,
Laura

Laura Abbott (2):
  mm/page_poison.c: Enable PAGE_POISONING as a separate option
  mm/page_poisoning.c: Allow for zero poisoning

 Documentation/kernel-parameters.txt |   5 +
 include/linux/mm.h                  |  11 +++
 include/linux/poison.h              |   4 +
 kernel/power/hibernate.c            |  17 ++++
 mm/Kconfig.debug                    |  39 +++++++-
 mm/Makefile                         |   2 +-
 mm/debug-pagealloc.c                | 137 ----------------------------
 mm/page_alloc.c                     |  13 ++-
 mm/page_ext.c                       |  10 +-
 mm/page_poison.c                    | 176 ++++++++++++++++++++++++++++++++++++
 10 files changed, 272 insertions(+), 142 deletions(-)
 delete mode 100644 mm/debug-pagealloc.c
 create mode 100644 mm/page_poison.c

-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
