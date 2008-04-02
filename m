From: Andrea Arcangeli <andrea@qumranet.com>
Subject: [ofa-general] [PATCH 0 of 8] mmu notifiers #v10
Date: Wed, 02 Apr 2008 23:30:01 +0200
Message-ID: <patchbomb.1207171801@duo.random>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <general-bounces@lists.openfabrics.org>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
To: akpm@linux-foundation.org
Cc: Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Izik Eidus <izike@qumranet.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Jack Steiner <steiner@sgi.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, Christoph Lameter <clameter@sgi.com>
List-Id: linux-mm.kvack.org

Hello,

this is the mmu notifier #v10. Patches 1 and 2 are the only difference between
this and EMM V2. The rest is the same as with Christoph's patches.

I think maximum priority should be given in merging patch 1 and 2 into -mm and
ASAP in mainline.

Patches from 3 to 8 can go in -mm for testing but I'm not sure if we should
support sleep capable notifiers in mainline unless we make the VM locking
conditional to avoid overscheduling for extremely small critical sections in
the common case. I only rediffed Christoph's patches on top of the mmu
notifier patches.

KVM current plans are to heavily depend on mmu notifiers for swapping, to
optimize the spte faults, and we need it for smp guest ballooning with
madvise(DONT_NEED) and other optimizations and features.

Patches from 3 to 8 are Christoph's work ported on top of #v10 to make the
#v10 mmu notifiers sleep capable (at least supposedly). I didn't test the
scheduling, but I assume you'll quickly test XPMEM on top of this.
