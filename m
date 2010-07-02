Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 589EF6B01B8
	for <linux-mm@kvack.org>; Fri,  2 Jul 2010 05:11:28 -0400 (EDT)
Date: Fri, 2 Jul 2010 11:11:24 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 4/7] hugetlb: add hugepage check in
 mem_cgroup_{register,end}_migration()
Message-ID: <20100702091124.GE12221@basil.fritz.box>
References: <1278049646-29769-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1278049646-29769-5-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1278049646-29769-5-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, Jul 02, 2010 at 02:47:23PM +0900, Naoya Horiguchi wrote:
> Currently memory cgroup doesn't charge hugepage,
> so avoid calling these functions in hugepage migration context.

Sounds like something that really should be fixed, but ok for now 
I guess...

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
