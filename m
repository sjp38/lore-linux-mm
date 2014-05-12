Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id D0D686B0037
	for <linux-mm@kvack.org>; Sun, 11 May 2014 23:06:26 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id rd3so7437863pab.1
        for <linux-mm@kvack.org>; Sun, 11 May 2014 20:06:26 -0700 (PDT)
Received: from na01-bl2-obe.outbound.protection.outlook.com (mail-bl2lp0204.outbound.protection.outlook.com. [207.46.163.204])
        by mx.google.com with ESMTPS id iv2si5643431pbd.168.2014.05.11.20.06.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 11 May 2014 20:06:26 -0700 (PDT)
From: Richard Lee <superlibj8301@gmail.com>
Subject: [RFC][PATCH 0/2] Add IO mapping space reused support
Date: Mon, 12 May 2014 10:19:53 +0800
Message-ID: <1399861195-21087-1-git-send-email-superlibj8301@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux@arm.linux.org.uk, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Richard Lee <superlibj8301@gmail.com>


Richard Lee (2):
  mm/vmalloc: Add IO mapping space reused interface.
  ARM: ioremap: Add IO mapping space reused support.

 arch/arm/mm/ioremap.c   | 11 ++++++++-
 include/linux/vmalloc.h |  5 ++++
 mm/vmalloc.c            | 63 +++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 78 insertions(+), 1 deletion(-)

-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
