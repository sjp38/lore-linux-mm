From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [RFC][PATCH 0/2] s390/kvm: add kvm support for guest page hinting v2
Date: Thu, 25 Jul 2013 10:54:19 +0200
Message-ID: <1374742461-29160-1-git-send-email-schwidefsky@de.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Nick Piggin <npiggin@kernel.dk>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
List-Id: linux-mm.kvack.org

v1->v2:
 - found a way to simplify the common code patch

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

The code is working stable now, from my point of view this is ready
for prime-time.

Konstantin Weitz (2):
  mm: add support for discard of unused ptes
  s390/kvm: support collaborative memory management

 arch/s390/include/asm/kvm_host.h |    5 ++-
 arch/s390/include/asm/pgtable.h  |   24 ++++++++++++
 arch/s390/kvm/kvm-s390.c         |   25 +++++++++++++
 arch/s390/kvm/kvm-s390.h         |    2 +
 arch/s390/kvm/priv.c             |   41 ++++++++++++++++++++
 arch/s390/mm/pgtable.c           |   77 ++++++++++++++++++++++++++++++++++++++
 include/asm-generic/pgtable.h    |   13 +++++++
 mm/rmap.c                        |   10 +++++
 8 files changed, 196 insertions(+), 1 deletion(-)

-- 
1.7.9.5
