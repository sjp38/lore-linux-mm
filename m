Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id E69646B0092
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 06:00:22 -0400 (EDT)
From: Lin Feng <linfeng@cn.fujitsu.com>
Subject: [PATCH 0/2] mm: vmemmap: add vmemmap_verify check for hot-add node/memory case
Date: Mon, 8 Apr 2013 17:56:38 +0800
Message-Id: <1365415000-10389-1-git-send-email-linfeng@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: cl@linux.com, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, yinghai@kernel.org, catalin.marinas@arm.com, will.deacon@arm.com, arnd@arndb.de, tony@atomide.com, ben@decadent.org.uk, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org, isimatu.yasuaki@jp.fujitsu.com, Lin Feng <linfeng@cn.fujitsu.com>

In hot add node(memory) case, vmemmap pages are always allocated from other
node, but the current logic just skip vmemmap_verify check. 
So we should also issue "potential offnode page_structs" warning messages
if we are the case

Lin Feng (2):
  mm: vmemmap: x86: add vmemmap_verify check for hot-add node case
  mm: vmemmap: arm64: add vmemmap_verify check for hot-add node case

 arch/arm64/mm/mmu.c   | 4 ++--
 arch/x86/mm/init_64.c | 6 ++++--
 2 files changed, 6 insertions(+), 4 deletions(-)

-- 
1.8.0.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
