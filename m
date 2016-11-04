Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 840CC6B02EC
	for <linux-mm@kvack.org>; Thu,  3 Nov 2016 22:47:46 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id n85so16918183pfi.4
        for <linux-mm@kvack.org>; Thu, 03 Nov 2016 19:47:46 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id d1si1863029pav.104.2016.11.03.19.47.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Nov 2016 19:47:45 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id n85so6464116pfi.3
        for <linux-mm@kvack.org>; Thu, 03 Nov 2016 19:47:45 -0700 (PDT)
Date: Fri, 4 Nov 2016 13:47:36 +1100
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [lkp] [mm]  731b9bc419: kernel BUG at
 include/linux/page-flags.h:259!
Message-ID: <20161104134736.5dfbad0b@roar.ozlabs.ibm.com>
In-Reply-To: <20161104023126.GE22769@yexl-desktop>
References: <20161102070346.12489-3-npiggin@gmail.com>
	<20161104023126.GE22769@yexl-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel test robot <xiaolong.ye@intel.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, lkp@01.org

On Fri, 4 Nov 2016 10:31:26 +0800
kernel test robot <xiaolong.ye@intel.com> wrote:

> [    0.680360] flags: 0x4000000000008000(head)
> [    0.681054] page dumped because: VM_BUG_ON_PAGE(1 && PageCompound(page))
> [    0.682146] ------------[ cut here ]------------
> [    0.682906] kernel BUG at include/linux/page-flags.h:259!

That's the bug Kirill noticed, I would say.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
