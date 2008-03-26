Message-Id: <20080326212347.466221000@polaris-admin.engr.sgi.com>
Date: Wed, 26 Mar 2008 14:23:47 -0700
From: Mike Travis <travis@sgi.com>
Subject: [PATCH 0/2] generic: simplify setup_nr_cpu_ids and add set_cpus_allowed_ptr
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Two simple patches to simplify setup_nr_cpu_ids and add a new function,
set_cpus_allowed_ptr().

Based on:
	git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git
	git://git.kernel.org/pub/scm/linux/kernel/git/x86/linux-2.6-x86.git


Signed-off-by: Mike Travis <travis@sgi.com>

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
