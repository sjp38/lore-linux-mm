Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 950C06B0031
	for <linux-mm@kvack.org>; Tue, 16 Jul 2013 11:53:05 -0400 (EDT)
Subject: [PATCH] mm: vmstats: tlb flush counters
From: Dave Hansen <dave@sr71.net>
Date: Tue, 16 Jul 2013 08:53:04 -0700
Message-Id: <20130716155304.AF1A88F8@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: x86@kernel.org, linux-mm@kvack.org, Dave Hansen <dave@sr71.net>

I was investigating some TLB flush scaling issues and realized
that we do not have any good methods for figuring out how many
TLB flushes we are doing.

It would be nice to be able to do these in generic code, but the
arch-independent calls don't explicitly specify whether we
actually need to do remote flushes or not.  In the end, we really
need to know if we actually _did_ global vs. local invalidations,
so that leaves us with few options other than to muck with the
counters from arch-specific code.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
