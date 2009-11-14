Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id EB9036B004D
	for <linux-mm@kvack.org>; Sat, 14 Nov 2009 13:10:23 -0500 (EST)
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id nAEIAMEc019905
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-mm@kvack.org>; Sat, 14 Nov 2009 13:10:22 -0500
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 00 of 25] Transparent Hugepage support #1
Message-Id: <patchbomb.1258220298@v2.random>
Date: Sat, 14 Nov 2009 17:38:18 -0000
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>
List-ID: <linux-mm.kvack.org>

Hello,

Lately I've been working to make KVM use hugepages transparently without the
usual restrictions of hugetlbfs. The RFC got postitive review so I splitted
the patches. Maybe they can be splitted more but this is a start and it should
allow for easier code review plus there was some more development ;). See
patch 24/25 for all detailed comments on this feature.

I'll be offline next week but I wanted to send the last updates so you can
more easily review latest status while I'm away.

TODO:

1) add proper sysfs support in preparation for khugepaged daemon tunes
   (obsolete the temporary/debug sysctl)

2) fixup smaps/pagemap stats (Adam you expressed interest in this area,
   if you have patches removing split_huge_page_* they're welcome ;)

3) create collapse_huge_page

4) add madvise(MADV_HUGEPAGE)

5) add khugepaged calling collapse_huge_page on madvise(MADV_HUGEPAGE) regions

6) potential removal of split_huge_page from mremap/mprotect (lowprio)

If you want to more easily interact with this patchset I uploaded a quilt tree
here:

	http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.32-rc7/transparent_hugepage-1/

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
