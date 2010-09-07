Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id CA63E6B0047
	for <linux-mm@kvack.org>; Tue,  7 Sep 2010 16:54:32 -0400 (EDT)
From: Gary King <gking@nvidia.com>
Subject: [PATCH] bounce: call flush_dcache_page after bounce_copy_vec
Date: Tue,  7 Sep 2010 13:45:34 -0700
Message-Id: <1283892334-9238-1-git-send-email-gking@nvidia.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-arm-kernel@lists.infradead.org, tj@kernel.org, linux-kernel@vger.kernel.org, Gary King <gking@nvidia.com>
List-ID: <linux-mm.kvack.org>

I have been seeing problems on Tegra 2 (ARMv7 SMP) systems with HIGHMEM
enabled on 2.6.35 (plus some patches targetted at 2.6.36 to perform
cache maintenance lazily), and the root cause appears to be that the
mm bouncing code is calling flush_dcache_page before it copies the
bounce buffer into the bio.

The patch below reorders these two operations, and eliminates numerous
arbitrary application crashes on my dev system.

Gary

--
