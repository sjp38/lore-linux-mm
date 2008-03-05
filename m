Message-Id: <20080305075237.608599000@menage.corp.google.com>
Date: Tue, 04 Mar 2008 23:52:37 -0800
From: menage@google.com
Subject: [PATCH 0/2] Cpuset hardwall flag:  Introduction
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: pj@sgi.com, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Currently the cpusets mem_exclusive flag is overloaded to mean both
"no-overlapping" and "no GFP_KERNEL allocations outside this cpuset".

These patches add a new mem_hardwall flag with just the allocation
restriction part of the mem_exclusive semantics, without breaking
backwards-compatibility for those who continue to use just
mem_exclusive. Additionally, the cgroup control file registration for
cpusets is cleaned up to reduce boilerplate.

Signed-off-by: Paul Menage <menage@google.com>

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
