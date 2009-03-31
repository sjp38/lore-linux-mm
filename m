Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id BC74D6B005C
	for <linux-mm@kvack.org>; Mon, 30 Mar 2009 20:01:26 -0400 (EDT)
From: Izik Eidus <ieidus@redhat.com>
Subject: [PATCH 0/2] kvm-userspace ksm support
Date: Tue, 31 Mar 2009 03:00:26 +0300
Message-Id: <1238457628-7668-1-git-send-email-ieidus@redhat.com>
Sender: owner-linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org, avi@redhat.com, aarcange@redhat.com, chrisw@redhat.com, riel@redhat.com, jeremy@goop.org, mtosatti@redhat.com, hugh@veritas.com, corbet@lwn.net, yaniv@redhat.com, dmonakhov@openvz.org, Izik Eidus <ieidus@redhat.com>
List-ID: <linux-mm.kvack.org>

Apply it against Avi kvm-userspace git tree.

Izik Eidus (2):
  qemu: add ksm support
  qemu: add ksmctl.

 qemu/ksm.h                 |   70 ++++++++++++++++++++++++++++++++++++++++++++
 qemu/vl.c                  |   34 +++++++++++++++++++++
 user/Makefile              |    6 +++-
 user/config-x86-common.mak |    2 +-
 user/ksmctl.c              |   69 +++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 179 insertions(+), 2 deletions(-)
 create mode 100644 qemu/ksm.h
 create mode 100644 user/ksmctl.c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
