Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 345CA280260
	for <linux-mm@kvack.org>; Fri,  3 Jul 2015 08:46:21 -0400 (EDT)
Received: by wicgi11 with SMTP id gi11so99445833wic.0
        for <linux-mm@kvack.org>; Fri, 03 Jul 2015 05:46:20 -0700 (PDT)
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com. [195.75.94.110])
        by mx.google.com with ESMTPS id w6si36277251wix.76.2015.07.03.05.46.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Fri, 03 Jul 2015 05:46:19 -0700 (PDT)
Received: from /spool/local
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dingel@linux.vnet.ibm.com>;
	Fri, 3 Jul 2015 13:46:18 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 4C0FE1B0806E
	for <linux-mm@kvack.org>; Fri,  3 Jul 2015 13:47:25 +0100 (BST)
Received: from d06av09.portsmouth.uk.ibm.com (d06av09.portsmouth.uk.ibm.com [9.149.37.250])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t63CkGpL28246206
	for <linux-mm@kvack.org>; Fri, 3 Jul 2015 12:46:16 GMT
Received: from d06av09.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av09.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t63CkFGx006500
	for <linux-mm@kvack.org>; Fri, 3 Jul 2015 06:46:16 -0600
From: Dominik Dingel <dingel@linux.vnet.ibm.com>
Subject: [PATCH 0/4] s390/mm: Fixup hugepage sw-emulated code removal
Date: Fri,  3 Jul 2015 14:46:05 +0200
Message-Id: <1435927569-41132-1-git-send-email-dingel@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux390@de.ibm.com, Dominik Dingel <dingel@linux.vnet.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Michael Holzheu <holzheu@linux.vnet.ibm.com>, linux-s390@vger.kernel.org, linux-mm@kvack.org, Gerald Schaefer <gerald.schaefer@de.ibm.com>

Heiko noticed that the current check for hugepage support on s390 is a little bit to
harsh as systems which do not support will crash.
The reason is that pageblock_order can now get negative when we set HPAGE_SHIFT to 0.
To avoid all this and to avoid opening another can of worms with enabling 
HUGETLB_PAGE_SIZE_VARIABLE I think it would be best to simply allow architectures to
define their own hugepages_supported().

Thanks
    Dominik

Dominik Dingel (4):
  Revert "s390/mm: change HPAGE_SHIFT type to int"
  Revert "s390/mm: make hugepages_supported a boot time decision"
  mm: hugetlb: allow hugepages_supported to be architecture specific
  s390/hugetlb: add hugepages_supported define

 arch/s390/include/asm/hugetlb.h |  1 +
 arch/s390/include/asm/page.h    |  8 ++++----
 arch/s390/kernel/setup.c        |  2 --
 arch/s390/mm/pgtable.c          |  2 --
 include/linux/hugetlb.h         | 17 ++++++++---------
 5 files changed, 13 insertions(+), 17 deletions(-)

-- 
2.3.8

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
