Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 00 of 12] mmu notifier #v13
Message-Id: <patchbomb.1208872276@duo.random>
Date: Tue, 22 Apr 2008 15:51:16 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <npiggin@suse.de>, Jack Steiner <steiner@sgi.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, akpm@linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>
List-ID: <linux-mm.kvack.org>

Hello,

This is the latest and greatest version of the mmu notifier patch #v13.

Changes are mainly in the mm_lock that uses sort() suggested by Christoph.
This reduces the complexity from O(N**2) to O(N*log(N)).

I folded the mm_lock functionality together with the mmu-notifier-core 1/12
patch to make it self-contained. I recommend merging 1/12 into -mm/mainline
ASAP. Lack of mmu notifiers is holding off KVM development. We are going to
rework the way the pages are mapped and unmapped to work with pure pfn for pci
passthrough without the use of page pinning, and we can't without mmu
notifiers. This is not just a performance matter.

KVM/GRU and AFAICT Quadrics are all covered by applying the single 1/12 patch
that shall be shipped with 2.6.26. The risk of brekage by applying 1/12 is
zero. Both when MMU_NOTIFIER=y and when it's =n, so it shouldn't be delayed
further.

XPMEM support comes with the later patches 2-12, risk for those patches is >0
and this is why the mmu-notifier-core is numbered 1/12 and not 12/12. Some are
simple and can go in immediately but not all are so simple.

2-12/12 are posted as usual for review by the VM developers and so Robin can
keep testing them on XPMEM and they can be merged later without any downside
(they're mostly orthogonal with 1/12).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
