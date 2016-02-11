Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 35EA76B0009
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 04:29:01 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fl4so14367754pad.0
        for <linux-mm@kvack.org>; Thu, 11 Feb 2016 01:29:01 -0800 (PST)
Received: from smtprelay.synopsys.com (us01smtprelay-2.synopsys.com. [198.182.47.9])
        by mx.google.com with ESMTPS id x77si11494686pfa.33.2016.02.11.01.29.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Feb 2016 01:29:00 -0800 (PST)
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: [PATCH 0/2] Enable s390/arc/sparc to use generic thp deposit/withdraw
Date: Thu, 11 Feb 2016 14:58:25 +0530
Message-ID: <1455182907-15445-1-git-send-email-vgupta@synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "David S. Miller" <davem@davemloft.net>, Alex Thorlton <athorlton@sgi.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-snps-arc@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Vineet Gupta <Vineet.Gupta1@synopsys.com>

Hi,

This came out my debugging THP on ARC. The generic deposit/withdraw routines
can be easily adapted to work with pgtable_t != struct page *.

Build/Run tested on ARC only.

Thx,
-Vineet

Vineet Gupta (2):
  mm,thp: refactor generic deposit/withdraw routines for wider usage
  ARC: mm: THP: use generic THP deposit/withdraw

 arch/arc/include/asm/hugepage.h |  8 --------
 arch/arc/mm/tlb.c               | 37 -------------------------------------
 mm/pgtable-generic.c            | 27 +++++++++++++++++----------
 3 files changed, 17 insertions(+), 55 deletions(-)

-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
