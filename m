Message-Id: <20080331154154.549122000@polaris-admin.engr.sgi.com>
Date: Mon, 31 Mar 2008 08:41:54 -0700
From: Mike Travis <travis@sgi.com>
Subject: [PATCH 0/1] numa: add function for node_to_cpumask_ptr
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Here is a small change to add the definition for a generic node_to_cpumask_ptr.
It isn't used in this patch, but allows other architectures to compile cleanly with
future changes coming to common kernel code.

Based on 2.6.25-rc5-mm1

Signed-off-by: Mike Travis <travis@sgi.com>

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
