Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 0 of 9] mmu notifier #v12
Message-Id: <patchbomb.1207669443@duo.random>
Date: Tue, 08 Apr 2008 17:44:03 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, Nick Piggin <npiggin@suse.de>, Steve Wise <swise@opengridcomputing.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Jack Steiner <steiner@sgi.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

The difference with #v11 is a different implementation of mm_lock that
guarantees handling signals in O(N). It's also more lowlatency friendly. 

Note that mmu_notifier_unregister may also fail with -EINTR if there are
signal pending or the system runs out of vmalloc space or physical memory,
only exit_mmap guarantees that any kernel module can be unloaded in presence
of an oom condition.

Either #v11 or the first three #v12 1,2,3 patches are suitable for inclusion
in -mm, pick what you prefer looking at the mmu_notifier_register retval and
mm_lock retval difference, I implemented and slighty tested both. GRU and KVM
only needs 1,2,3, XPMEM needs the rest of the patchset too (4, ...) but all
patches from 4 to the end can be deffered to a second merge window.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
