Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f169.google.com (mail-we0-f169.google.com [74.125.82.169])
	by kanga.kvack.org (Postfix) with ESMTP id 6F49C6B006C
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 03:58:19 -0500 (EST)
Received: by mail-we0-f169.google.com with SMTP id m14so13386588wev.0
        for <linux-mm@kvack.org>; Thu, 15 Jan 2015 00:58:19 -0800 (PST)
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com. [195.75.94.111])
        by mx.google.com with ESMTPS id go6si30896375wib.52.2015.01.15.00.58.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 15 Jan 2015 00:58:16 -0800 (PST)
Received: from /spool/local
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Thu, 15 Jan 2015 08:58:16 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 3C84917D8056
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 08:58:51 +0000 (GMT)
Received: from d06av05.portsmouth.uk.ibm.com (d06av05.portsmouth.uk.ibm.com [9.149.37.229])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t0F8wCUP38207570
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 08:58:12 GMT
Received: from d06av05.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av05.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t0F8wB0P009575
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 01:58:12 -0700
From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: [PATCH 0/8] current ACCESS_ONCE patch queue
Date: Thu, 15 Jan 2015 09:58:26 +0100
Message-Id: <1421312314-72330-1-git-send-email-borntraeger@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-arch@vger.kernel.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, xen-devel@lists.xenproject.org, linux-mm@kvack.org, Christian Borntraeger <borntraeger@de.ibm.com>

Folks,

fyi, this is my current patch queue for the next merge window. It
does contain a patch that will disallow ACCESS_ONCE on non-scalar
types.

The tree is part of linux-next and can be found at
git://git.kernel.org/pub/scm/linux/kernel/git/borntraeger/linux.git linux-next


Christian Borntraeger (7):
  ppc/kvm: Replace ACCESS_ONCE with READ_ONCE
  ppc/hugetlbfs: Replace ACCESS_ONCE with READ_ONCE
  x86/xen/p2m: Replace ACCESS_ONCE with READ_ONCE
  x86/spinlock: Leftover conversion ACCESS_ONCE->READ_ONCE
  mm/gup: Replace ACCESS_ONCE with READ_ONCE
  kernel: tighten rules for ACCESS ONCE
  kernel: Fix sparse warning for ACCESS_ONCE

Guenter Roeck (1):
  next: sh: Fix compile error

 arch/powerpc/kvm/book3s_hv_rm_xics.c |  8 ++++----
 arch/powerpc/kvm/book3s_xics.c       | 16 ++++++++--------
 arch/powerpc/mm/hugetlbpage.c        |  4 ++--
 arch/sh/mm/gup.c                     |  2 +-
 arch/x86/include/asm/spinlock.h      |  2 +-
 arch/x86/xen/p2m.c                   |  2 +-
 include/linux/compiler.h             | 21 ++++++++++++++++-----
 mm/gup.c                             |  2 +-
 8 files changed, 34 insertions(+), 23 deletions(-)

-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
