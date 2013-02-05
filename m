Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 682D26B0002
	for <linux-mm@kvack.org>; Tue,  5 Feb 2013 13:12:13 -0500 (EST)
Received: from /spool/local
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Tue, 5 Feb 2013 18:10:56 -0000
Received: from d06av05.portsmouth.uk.ibm.com (d06av05.portsmouth.uk.ibm.com [9.149.37.229])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r15IC19e27459744
	for <linux-mm@kvack.org>; Tue, 5 Feb 2013 18:12:01 GMT
Received: from d06av05.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av05.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r15IC97H002070
	for <linux-mm@kvack.org>; Tue, 5 Feb 2013 11:12:10 -0700
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [PATCH] software dirty bits for s390
Date: Tue,  5 Feb 2013 10:12:03 -0800
Message-Id: <1360087925-8456-1-git-send-email-schwidefsky@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-s390@vger.kernel.org
Cc: Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Jan Kara <jack@suse.cz>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

Greetings,

good news, I got performance results for a selected set of workloads
with my software dirty bit patch (thanks Christian!). We found no
downsides to the software dirty bits, and a substantial improvement
in CPU utilization for the FIO test with mostly read mappings.

All good, the patch can now go upstream. The patch changes common
memory management code but the parts that are removed are purely
s390 specific. I can handle it via the linux-s390 tree but I would
not mind if it gets the sign-off by the mm folks.

Martin Schwidefsky (1):
  s390/mm: implement software dirty bits

 arch/s390/include/asm/page.h    |   22 -------
 arch/s390/include/asm/pgtable.h |  131 ++++++++++++++++++++++++++-------------
 arch/s390/include/asm/sclp.h    |    1 -
 arch/s390/include/asm/setup.h   |   16 ++---
 arch/s390/kvm/kvm-s390.c        |    2 +-
 arch/s390/lib/uaccess_pt.c      |    2 +-
 arch/s390/mm/pageattr.c         |    2 +-
 arch/s390/mm/vmem.c             |   24 +++----
 drivers/s390/char/sclp_cmd.c    |   10 +--
 include/asm-generic/pgtable.h   |   10 ---
 include/linux/page-flags.h      |    8 ---
 mm/rmap.c                       |   24 -------
 12 files changed, 112 insertions(+), 140 deletions(-)

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
