Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 8E0136B007E
	for <linux-mm@kvack.org>; Mon, 21 Mar 2016 05:49:59 -0400 (EDT)
Received: by mail-pf0-f178.google.com with SMTP id n5so258868923pfn.2
        for <linux-mm@kvack.org>; Mon, 21 Mar 2016 02:49:59 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id 65si16953280pfi.145.2016.03.21.02.49.58
        for <linux-mm@kvack.org>;
        Mon, 21 Mar 2016 02:49:58 -0700 (PDT)
Date: Mon, 21 Mar 2016 17:48:25 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH v2 17/18] zsmalloc: migrate tail pages in zspage
Message-ID: <201603211705.9hgJl8K7%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1458541867-27380-18-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jlayton@poochiereds.net, bfields@fieldses.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, koct9i@gmail.com, aquini@redhat.com, virtualization@lists.linux-foundation.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Rik van Riel <riel@redhat.com>, rknize@motorola.com, Gioh Kim <gi-oh.kim@profitbricks.com>, Sangseok Lee <sangseok.lee@lge.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Al Viro <viro@ZenIV.linux.org.uk>, YiPing Xu <xuyiping@hisilicon.com>

Hi Minchan,

[auto build test WARNING on next-20160318]
[cannot apply to v4.5-rc7 v4.5-rc6 v4.5-rc5 v4.5]
[if your patch is applied to the wrong git tree, please drop us a note to help improving the system]

url:    https://github.com/0day-ci/linux/commits/Minchan-Kim/Support-non-lru-page-migration/20160321-143339


coccinelle warnings: (new ones prefixed by >>)

>> mm/zsmalloc.c:1103:2-3: Unneeded semicolon

Please review and possibly fold the followup patch.

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
