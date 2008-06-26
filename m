Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 0 of 3] mmu notifier v18 for -mm
Message-Id: <patchbomb.1214440016@duo.random>
Date: Thu, 26 Jun 2008 02:26:56 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, Robin Holt <holt@sgi.com>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm@vger.kernel.org, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, Rusty Russell <rusty@rustcorp.com.au>, Anthony Liguori <aliguori@us.ibm.com>, Chris Wright <chrisw@redhat.com>, Marcelo Tosatti <marcelo@kvack.org>, Eric Dumazet <dada1@cosmosbay.com>, "Paul E. McKenney" <paulmck@us.ibm.com>, Izik Eidus <izike@qumranet.com>Anthony Liguori <aliguori@us.ibm.com>, Rik van Riel <riel@redhat.com>
Cc: andrea@qumranet.com
List-ID: <linux-mm.kvack.org>

Hello,

Christoph suggested me to repost v18 for merging in -mm, to give it more
exposure before the .27 merge window opens. There's no code change compared to
the previous v18 submission (the only change is the correction in the comment
in the mm_take_all_locks patch rightfully pointed out by Linus).

Full patchset including other XPMEM support patches can be found here:

	http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.26-rc7/mmu-notifier-v18

Only the three patches of the patchset I'm submitting here by email are ready
for merging, the rest you can find in the website is not ready for merging yet
for various performance degradations, lots of the XPMEM patches needs to be
elaborated to avoid any slowdown for the non-XPMEM case, but I keep
maintaining them to make life easier to XPMEM current development and later we
can keep work on them to make them suitable for inclusion to avoid any
performance degradation risk.

(the fourth patch in the series of the above url, is not strictly relealted to
mmu notifiers but it's good at least for me to keep it in the same tree to
test pci-passthrough capable guest running on reserved-ram at the same time of
two regular guests swapping heavily with mmu notifiers which tends to
exercises both spte models at the same time, if you find this confusing I'll
remove it from any later upload, but xpmem users can totally ignore it, it
only touches x86-64 code)

Thanks a lot.
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
