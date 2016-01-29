Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f179.google.com (mail-qk0-f179.google.com [209.85.220.179])
	by kanga.kvack.org (Postfix) with ESMTP id 6FFC66B0009
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 12:53:53 -0500 (EST)
Received: by mail-qk0-f179.google.com with SMTP id o6so27322794qkc.2
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 09:53:53 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b15si18719610qge.125.2016.01.29.09.53.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jan 2016 09:53:52 -0800 (PST)
Date: Fri, 29 Jan 2016 18:53:49 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [LSF/MM ATTEND] 2016 userfaultfd/KSMscale/THP
Message-ID: <20160129175349.GL12228@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org

Hello,

I'd like to attend this year LSF/MM summit. Possible topics that I
would suggest are:

o the userfaultfd syscall has been merged upstream and it's feature
  complete for KVM postcopy live migration (available in current
  upstream QEMU).

  The extension to provide the write tracking feature to userfaultfd
  was planned from the start and an implementation has already been
  posted. The current implementation works fine for simple cases but
  it's not fully complete yet (no mmu notifier, THP not working
  etc..). The API of the new ioctls for the write protection feature
  should be finalized before this can be merged in -mm/upstream and
  the summit would be a good opportunity to discuss it. By April I
  expect a fully functional implementation of the new feature would
  become available.

  The topic to extend the userfaultfd syscalls to hugetlbfs has
  already been proposed. I'm interested about following up that too
  and not just to hugetlbfs but in general to extend it to more
  filebacked vmas types.

o KSMscale: a change needed to reduce the worst case computational
  complexity of KSM is pending. This is needed to avoid long (as in
  seconds) CPU stalls in the rmap_walks (or alternatively the random
  materialization of unmovable pages anywhere in the physical ranges
  of supposedly movable memblocks and movable zones) on systems with
  larges amount of RAM and/or with dense workloads like clear
  containers. Perhaps by April this will already have been fully
  sorted out online and the patch will be already upstream, in which
  case this topic would be obsolete and should be skipped, but if not,
  I'd be nice to discuss this too.

o TLB flushing reduction in the rmap_walks: Mel and Hugh started
  various work in this area. Patches have been posted for a certain
  number of cases but it'd be good if we could optimize things for
  secondary MMUs (i.e. KVM MMU notifiers) too and for more cases.

Last but not the least I'm also very interested about following the
Huge Page (Huge Page as in Transparent Huge Pages I assume) Futures
topic already proposed.

Thanks and hope to see you soon!
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
