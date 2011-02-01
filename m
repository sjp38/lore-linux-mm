Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 658EC8D0039
	for <linux-mm@kvack.org>; Tue,  1 Feb 2011 06:21:51 -0500 (EST)
From: Gleb Natapov <gleb@redhat.com>
Subject: [PATCH 0/2] KVM: enable asynchronous page faults
Date: Tue,  1 Feb 2011 13:21:45 +0200
Message-Id: <1296559307-14637-1-git-send-email-gleb@redhat.com>
Sender: owner-linux-mm@kvack.org
To: avi@redhat.com, mtosatti@redhat.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

This patch series is on top of Huang Ying "Replace is_hwpoison_address with
__get_user_pages" series: http://www.mail-archive.com/kvm@vger.kernel.org/msg48776.html

Gleb Natapov (2):
  Allow GUP to fail instead of waiting on a page.
  KVM: Enable async page fault processing.

 include/linux/mm.h  |    2 ++
 mm/filemap.c        |    6 ++++--
 mm/memory.c         |    5 ++++-
 virt/kvm/kvm_main.c |   23 +++++++++++++++++++++--
 4 files changed, 31 insertions(+), 5 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
