Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id E67416B004D
	for <linux-mm@kvack.org>; Fri, 16 Mar 2012 15:28:20 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH] numa_emulation fix
Date: Fri, 16 Mar 2012 20:28:10 +0100
Message-Id: <1331926091-22548-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-numa@vger.kernel.org
Cc: Andi Kleen <andi@firstfloor.org>, Johannes Weiner <jweiner@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

Hi,

basically without this various debug checks in AutoNUMA triggers and
the kernel crashes because a CPU can't belong to more than one node,
can it?

I've been using this fix for some time to develop in virt with fake
numa without problems (like real hardware).

Andrea Arcangeli (1):
  numa_emulation: fix cpumask_of_node()

 arch/x86/mm/numa_emulation.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
