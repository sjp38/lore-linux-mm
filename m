Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id E9CB06B003B
	for <linux-mm@kvack.org>; Mon, 29 Apr 2013 10:56:05 -0400 (EDT)
Received: by mail-we0-f181.google.com with SMTP id m1so5365862wea.12
        for <linux-mm@kvack.org>; Mon, 29 Apr 2013 07:56:04 -0700 (PDT)
From: Steve Capper <steve.capper@linaro.org>
Subject: [RFC PATCH 0/2] mm: Promote huge_pmd_share from x86 to mm.
Date: Mon, 29 Apr 2013 15:55:54 +0100
Message-Id: <1367247356-11246-1-git-send-email-steve.capper@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org
Cc: Michal Hocko <mhocko@suse.cz>, Ken Chen <kenchen@google.com>, Mel Gorman <mgorman@suse.de>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Steve Capper <steve.capper@linaro.org>

Under x86, multiple puds can be made to reference the same bank of
huge pmds provided that they represent a full PUD_SIZE of shared
huge memory that is aligned to a PUD_SIZE boundary.

The code to share pmds does not require any architecture specific
knowledge other than the fact that pmds can be indexed, thus can
be beneficial to some other architectures.

This RFC promotes the huge_pmd_share code (and dependencies) from
x86 to mm to make it accessible to other architectures.

I am working on ARM64 support for huge pages and rather than
duplicate the x86 huge_pmd_share code, I thought it would be better
to promote it to mm.

Comments would be very welcome.

Cheers,
-- 
Steve

Steve Capper (2):
  mm: hugetlb: Copy huge_pmd_share from x86 to mm.
  x86: mm: Remove x86 version of huge_pmd_share.

 arch/x86/Kconfig          |   3 ++
 arch/x86/mm/hugetlbpage.c | 120 ---------------------------------------------
 include/linux/hugetlb.h   |   4 ++
 mm/hugetlb.c              | 122 ++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 129 insertions(+), 120 deletions(-)

-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
