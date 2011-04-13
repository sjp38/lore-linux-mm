Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 4DC67900086
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 05:06:50 -0400 (EDT)
Message-Id: <20110413085937.981293444@intel.com>
Date: Wed, 13 Apr 2011 16:59:37 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 0/4] trivial writeback fixes
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org

Andrew,

Here are four trivial writeback fix patches that
should work well for the patches from both Jan and me.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
