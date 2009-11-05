Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id EB99B6B0062
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 15:21:13 -0500 (EST)
Subject: [PATCH v2 0/3] Documentation/vm/page-types enhancements
From: Alex Chiang <achiang@hp.com>
Date: Thu, 05 Nov 2009 13:21:11 -0700
Message-ID: <20091105201846.25492.52935.stgit@bob.kio>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, fengguang.wu@intel.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

This is v2 of teaching page-types to decode page flags directly from
the command line.

v1 -> v2:
	- Use Fengguang's implementation
	- Exit early when using new -d|--describe option

---

Alex Chiang (2):
      page-types: whitespace alignment
      page-types: exit early when invoked with -d|--describe

Wu Fengguang (1):
      page-types: learn to describe flags directly from command line


 Documentation/vm/page-types.c |   60 +++++++++++++++++++++++++++--------------
 1 files changed, 39 insertions(+), 21 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
