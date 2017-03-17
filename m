Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 29FF06B038C
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 14:25:19 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id c85so77850987qkg.0
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 11:25:19 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i23si7045614qta.103.2017.03.17.11.25.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Mar 2017 11:25:18 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [HMM 0/2] Build fix and documentation
Date: Fri, 17 Mar 2017 15:27:01 -0400
Message-Id: <1489778823-8694-1-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

This fix build on 32 bit system by simply disabling this feature as
it was never intented for 32 bit system. This also add documentations.

Size impact is virtualy non-existent (allyesconfig on i386 without
patchset and then with whole patchset and build fixes).

[glisse@localhost linux]$ size vmlinux-without 
   text	   data	    bss	    dec	    hex	filename
73065929	43745211	26939392	143750532	8917584	vmlinux-without
[glisse@localhost linux]$ size vmlinux
   text	   data	    bss	    dec	    hex	filename
73066001	43745211	26939392	143750604	89175cc	vmlinux

Sorry for all the build failures.

Cheers,
JA(C)rA'me


Balbir Singh (1):
  mm/hmm: Fix build on 32 bit systems

JA(C)rA'me Glisse (1):
  hmm: heterogeneous memory management documentation

 Documentation/vm/hmm.txt | 362 +++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/migrate.h  |  18 ++-
 mm/Kconfig               |   4 +-
 mm/migrate.c             |   3 +-
 4 files changed, 384 insertions(+), 3 deletions(-)
 create mode 100644 Documentation/vm/hmm.txt

-- 
2.4.11

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
