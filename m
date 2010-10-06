Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id CD30B6B0085
	for <linux-mm@kvack.org>; Wed,  6 Oct 2010 16:57:35 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: HWPOISON huge page signal fixes
Date: Wed,  6 Oct 2010 22:57:19 +0200
Message-Id: <1286398641-11862-1-git-send-email-andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, fengguang.wu@intel.com, n-horiguchi@ah.jp.nec.com, x86@kernel.org
List-ID: <linux-mm.kvack.org>

These patches fix the address granuality reporting for hugepage
hwpoison errors. This requires some straight forward changes
in the MM (to return this information from handle_mm_fault)
and in the x86 fault handler (to pass this information on)

Any reviews and acks appreciated.

I plan to carry this in my tree for now. Targetted for 2.6.37

Thanks,
-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
