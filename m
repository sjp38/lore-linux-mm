Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id E8D556B0034
	for <linux-mm@kvack.org>; Wed,  3 Jul 2013 09:02:07 -0400 (EDT)
Received: from /spool/local
	by e06smtp16.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Wed, 3 Jul 2013 13:56:40 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 2BCAE17D805C
	for <linux-mm@kvack.org>; Wed,  3 Jul 2013 14:03:35 +0100 (BST)
Received: from d06av08.portsmouth.uk.ibm.com (d06av08.portsmouth.uk.ibm.com [9.149.37.249])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r63D1qsp27197592
	for <linux-mm@kvack.org>; Wed, 3 Jul 2013 13:01:52 GMT
Received: from d06av08.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av08.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r63D23Dq004127
	for <linux-mm@kvack.org>; Wed, 3 Jul 2013 07:02:03 -0600
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [RFC][PATCH 0/2] s390/kvm: add kvm support for guest page hinting
Date: Wed,  3 Jul 2013 15:01:50 +0200
Message-Id: <1372856512-25710-1-git-send-email-schwidefsky@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Nick Piggin <npiggin@kernel.dk>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>

Linux on s390 as a guest under z/VM has been using the guest page
hinting interface (alias collaborative memory management) for a long
time. The full version with volatile states has been deemed to be too
complicated (see the old discussion about guest page hinting e.g. on
http://marc.info/?l=linux-mm&m=123816662017742&w=2).
What is currently implemented for the guest is the unused and stable
states to mark unallocated pages as freely available to the host.
This works just fine with z/VM as the host.

The two patches in this series implement the guest page hinting
interface for the unused and stable states in the KVM host.
Most of the code specific to s390 but there is a common memory
management part as well, see patch #1.

The circus is back ;-)

Konstantin Weitz (2):
  mm: add support for discard of unused ptes
  s390/kvm: support collaborative memory management

 arch/s390/include/asm/kvm_host.h |    8 +++-
 arch/s390/include/asm/pgtable.h  |   24 ++++++++++++
 arch/s390/kvm/kvm-s390.c         |   24 ++++++++++++
 arch/s390/kvm/kvm-s390.h         |    2 +
 arch/s390/kvm/priv.c             |   37 ++++++++++++++++++
 arch/s390/mm/pgtable.c           |   77 ++++++++++++++++++++++++++++++++++++++
 include/asm-generic/pgtable.h    |   13 +++++++
 include/linux/rmap.h             |    1 +
 mm/rmap.c                        |   28 +++++++++++++-
 mm/vmscan.c                      |    3 ++
 10 files changed, 214 insertions(+), 3 deletions(-)

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
