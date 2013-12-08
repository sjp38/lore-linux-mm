Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f50.google.com (mail-ee0-f50.google.com [74.125.83.50])
	by kanga.kvack.org (Postfix) with ESMTP id 5354E6B0035
	for <linux-mm@kvack.org>; Sat,  7 Dec 2013 20:12:28 -0500 (EST)
Received: by mail-ee0-f50.google.com with SMTP id c41so908920eek.23
        for <linux-mm@kvack.org>; Sat, 07 Dec 2013 17:12:27 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id i1si3821567eev.26.2013.12.07.17.12.25
        for <linux-mm@kvack.org>;
        Sat, 07 Dec 2013 17:12:25 -0800 (PST)
Message-ID: <52A3C75A.1030605@redhat.com>
Date: Sat, 07 Dec 2013 20:11:54 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 1/6] sched/numa: fix set cpupid on page migration twice
References: <1386321136-27538-1-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1386321136-27538-1-git-send-email-liwanp@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 12/06/2013 04:12 AM, Wanpeng Li wrote:
> commit 7851a45cd3 (mm: numa: Copy cpupid on page migration) copy over 
> the cpupid at page migration time, there is unnecessary to set it again 
> in migrate_misplaced_transhuge_page, this patch fix it.
> 
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
