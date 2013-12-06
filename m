Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f52.google.com (mail-bk0-f52.google.com [209.85.214.52])
	by kanga.kvack.org (Postfix) with ESMTP id B14EC6B0062
	for <linux-mm@kvack.org>; Fri,  6 Dec 2013 11:56:34 -0500 (EST)
Received: by mail-bk0-f52.google.com with SMTP id u14so390150bkz.25
        for <linux-mm@kvack.org>; Fri, 06 Dec 2013 08:56:34 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id j47si15446282eeo.32.2013.12.06.08.56.33
        for <linux-mm@kvack.org>;
        Fri, 06 Dec 2013 08:56:33 -0800 (PST)
Date: Fri, 6 Dec 2013 16:56:23 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v2 1/6] sched/numa: fix set cpupid on page migration twice
Message-ID: <20131206165623.GR11295@suse.de>
References: <1386321136-27538-1-git-send-email-liwanp@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1386321136-27538-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Dec 06, 2013 at 05:12:11PM +0800, Wanpeng Li wrote:
> commit 7851a45cd3 (mm: numa: Copy cpupid on page migration) copy over 
> the cpupid at page migration time, there is unnecessary to set it again 
> in migrate_misplaced_transhuge_page, this patch fix it.
> 
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
