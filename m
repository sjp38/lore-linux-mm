Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f179.google.com (mail-ea0-f179.google.com [209.85.215.179])
	by kanga.kvack.org (Postfix) with ESMTP id 49EAF6B0074
	for <linux-mm@kvack.org>; Fri,  6 Dec 2013 11:57:41 -0500 (EST)
Received: by mail-ea0-f179.google.com with SMTP id r15so428217ead.38
        for <linux-mm@kvack.org>; Fri, 06 Dec 2013 08:57:40 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id a9si13653488eew.243.2013.12.06.08.57.25
        for <linux-mm@kvack.org>;
        Fri, 06 Dec 2013 08:57:25 -0800 (PST)
Date: Fri, 6 Dec 2013 16:57:21 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v2 4/6] sched/numa: use wrapper function task_node to get
 node which task is on
Message-ID: <20131206165721.GT11295@suse.de>
References: <1386321136-27538-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1386321136-27538-4-git-send-email-liwanp@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1386321136-27538-4-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Dec 06, 2013 at 05:12:14PM +0800, Wanpeng Li wrote:
> Use wrapper function task_node to get node which task is on.
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
