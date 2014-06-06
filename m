Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f54.google.com (mail-qa0-f54.google.com [209.85.216.54])
	by kanga.kvack.org (Postfix) with ESMTP id 77BCE6B0095
	for <linux-mm@kvack.org>; Fri,  6 Jun 2014 13:51:33 -0400 (EDT)
Received: by mail-qa0-f54.google.com with SMTP id j15so4322701qaq.41
        for <linux-mm@kvack.org>; Fri, 06 Jun 2014 10:51:33 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id e3si14291883qaa.112.2014.06.06.10.51.32
        for <linux-mm@kvack.org>;
        Fri, 06 Jun 2014 10:51:32 -0700 (PDT)
Date: Fri, 6 Jun 2014 13:51:25 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: 3.15-rc8 oops in copy_page_rep after page fault.
Message-ID: <20140606175125.GB1741@redhat.com>
References: <20140606174317.GA1741@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140606174317.GA1741@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>

On Fri, Jun 06, 2014 at 01:43:17PM -0400, Dave Jones wrote:
 > Not much to go on here. It rebooted right after dumping this.
 > 
 > RIP: 0010:[<ffffffff8b3287b5>]  [<ffffffff8b3287b5>] copy_page_rep+0x5/0x10
 > Call Trace:
 >  [<ffffffff8b1be8db>] ? do_huge_pmd_wp_page+0x5cb/0x850
 >  [<ffffffff8b187010>] handle_mm_fault+0x1e0/0xc50
 >  [<ffffffff8b1b4662>] ? kmem_cache_free+0x1c2/0x200
 >  [<ffffffff8b7472d9>] __do_page_fault+0x1c9/0x630
 >  [<ffffffff8b010a98>] ? perf_trace_sys_enter+0x38/0x180
 >  [<ffffffff8b11897b>] ? __acct_update_integrals+0x8b/0x120
 >  [<ffffffff8b747bfb>] ? preempt_count_sub+0xab/0x100
 >  [<ffffffff8b74775e>] do_page_fault+0x1e/0x70
 >  [<ffffffff8b7441b2>] page_fault+0x22/0x30

Ok, I can reproduce this fairly easily.

The only prerequisite seems to be that before I start the fuzzer I do..

echo 65536 > /proc/sys/vm/mmap_min_addr

If I don't do that, then it seems to survive, so maybe that's a clue ?

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
