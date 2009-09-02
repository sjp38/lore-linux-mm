From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [RFC][PATCH 0/4] move tools in Documentation/vm/ to tools/vm/
Date: Wed, 02 Sep 2009 11:41:25 +0800
Message-ID: <20090902034125.718886329@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 77F9D6B005A
	for <linux-mm@kvack.org>; Wed,  2 Sep 2009 00:02:40 -0400 (EDT)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, "Wu, Fengguang" <fengguang.wu@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Randy Dunlap <randy.dunlap@oracle.com>, Chris Wright <chrisw@redhat.com>, "Huang, Ying" <ying.huang@intel.com>, Lin Ming <ming.m.lin@intel.com>, Josh Triplett <josh@joshtriplett.org>, Andi Kleen <andi@firstfloor.org>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

Hi all,

3 useful tools (which are more than code examples) in Documentation/vm/
	- page-types
	- slabinfo
	- slqbinfo
are moved to tools/vm/, and page-types is updated to support two new flags.

The tools can be compiled together by

	make tools/vm/

Note that checkpatch complains some style problems on slabinfo.c/slqbinfo.c,
which are leaved as is.

Thanks,
Fengguang
-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
