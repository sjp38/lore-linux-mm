From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 0/5] [RFC] HWPOISON incremental fixes
Date: Thu, 11 Jun 2009 22:22:39 +0800
Message-ID: <20090611142239.192891591@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id E5A536B0055
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 10:52:16 -0400 (EDT)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Andi Kleen <andi@firstfloor.org>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Wu, Fengguang" <fengguang.wu@intel.com>
List-Id: linux-mm.kvack.org

Hi all,

Here are the hwpoison fixes that aims to address Nick and Hugh's concerns.
Note that
- the early kill option is dropped for .31. It's obscure option and complex
  code and is not must have for .31. Maybe Andi also aims this option for
  notifying KVM, but right now KVM is not ready to handle that.
- It seems that even fsync() processes are not easy to catch, so I abandoned
  the SIGKILL on fsync() idea. Instead, I choose to fail any attempt to
  populate the poisoned file with new pages, so that the corrupted page offset
  won't be repopulated with outdated data. This seems to be a safe way to allow
  the process to continue running while still be able to promise good (but not
  complete) data consistency.
- I didn't implement the PANIC-on-corrupted-data option. Instead, I guess
  sending uevent notification to user space will be a more flexible scheme?

Thanks,
Fengguang
-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
