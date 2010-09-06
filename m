Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id D0A866B004A
	for <linux-mm@kvack.org>; Mon,  6 Sep 2010 18:08:03 -0400 (EDT)
Date: Tue, 7 Sep 2010 00:07:35 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] avoid warning when COMPACTION is selected
Message-ID: <20100906220735.GS16761@random.random>
References: <20100903153826.GB16761@random.random>
 <20100903130623.00da1f96.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100903130623.00da1f96.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Sep 03, 2010 at 01:06:23PM -0700, Andrew Morton wrote:
> Could you please send along a copy of the warning?  It's unclear

Sure.

> whether it's a compiler warning or a Kconfig warning or a runtime
> warning or what.

Kconfig warning.

scripts/kconfig/conf --oldconfig arch/x86/Kconfig
warning: (COMPACTION && EXPERIMENTAL && HUGETLB_PAGE && MMU) selects MIGRATION which has unmet direct dependencies (NUMA || ARCH_ENABLE_MEMORY_HOTREMOVE)
warning: (COMPACTION && EXPERIMENTAL && HUGETLB_PAGE && MMU) selects MIGRATION which has unmet direct dependencies (NUMA || ARCH_ENABLE_MEMORY_HOTREMOVE)
#
# configuration written to .config
#

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
