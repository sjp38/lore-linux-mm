Date: Sat, 3 May 2008 06:09:04 -0500
From: Jack Steiner <steiner@sgi.com>
Subject: Re: [PATCH 00 of 11] mmu notifier #v15
Message-ID: <20080503110904.GA19688@sgi.com>
References: <patchbomb.1209740703@duo.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <patchbomb.1209740703@duo.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, Robin Holt <holt@sgi.com>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, Rusty Russell <rusty@rustcorp.com.au>, Anthony Liguori <aliguori@us.ibm.com>, Chris Wright <chrisw@redhat.com>, Marcelo Tosatti <marcelo@kvack.org>, Eric Dumazet <dada1@cosmosbay.com>, "Paul E. McKenney" <paulmck@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, May 02, 2008 at 05:05:03PM +0200, Andrea Arcangeli wrote:
> Hello everyone,
> 
> 1/11 is the latest version of the mmu-notifier-core patch.
> 
> As usual all later 2-11/11 patches follows but those aren't meant for 2.6.26.
> 

Not sure why -mm is different, but I get compile errors w/o the following...

--- jack


Index: linux/mm/mmu_notifier.c
===================================================================
--- linux.orig/mm/mmu_notifier.c	2008-05-02 16:54:52.780576831 -0500
+++ linux/mm/mmu_notifier.c	2008-05-02 16:56:38.817719509 -0500
@@ -16,6 +16,7 @@
 #include <linux/srcu.h>
 #include <linux/rcupdate.h>
 #include <linux/sched.h>
+#include <linux/rculist.h>
 
 /*
  * This function can't run concurrently against mmu_notifier_register

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
