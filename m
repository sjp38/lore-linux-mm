Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id EDB196B005A
	for <linux-mm@kvack.org>; Mon, 30 Mar 2009 20:01:02 -0400 (EDT)
From: Izik Eidus <ieidus@redhat.com>
Subject: [PATCH 0/3] kvm support for ksm
Date: Tue, 31 Mar 2009 03:00:01 +0300
Message-Id: <1238457604-7637-1-git-send-email-ieidus@redhat.com>
Sender: owner-linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org, avi@redhat.com, aarcange@redhat.com, chrisw@redhat.com, riel@redhat.com, jeremy@goop.org, mtosatti@redhat.com, hugh@veritas.com, corbet@lwn.net, yaniv@redhat.com, dmonakhov@openvz.org, Izik Eidus <ieidus@redhat.com>
List-ID: <linux-mm.kvack.org>

apply it against Avi git tree.

Izik Eidus (3):
  kvm: dont hold pagecount reference for mapped sptes pages.
  kvm: add SPTE_HOST_WRITEABLE flag to the shadow ptes.
  kvm: add support for change_pte mmu notifiers

 arch/x86/include/asm/kvm_host.h |    1 +
 arch/x86/kvm/mmu.c              |   89 ++++++++++++++++++++++++++++++++-------
 arch/x86/kvm/paging_tmpl.h      |   16 ++++++-
 virt/kvm/kvm_main.c             |   14 ++++++
 4 files changed, 101 insertions(+), 19 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
