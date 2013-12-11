Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f47.google.com (mail-bk0-f47.google.com [209.85.214.47])
	by kanga.kvack.org (Postfix) with ESMTP id AC3FF6B0036
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 04:02:08 -0500 (EST)
Received: by mail-bk0-f47.google.com with SMTP id mx12so187856bkb.6
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 01:02:07 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id uo7si8044741bkb.328.2013.12.11.01.02.07
        for <linux-mm@kvack.org>;
        Wed, 11 Dec 2013 01:02:07 -0800 (PST)
Date: Wed, 11 Dec 2013 09:02:04 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v5 5/8] sched/numa: use wrapper function task_faults_idx
 to calculate index in group_faults
Message-ID: <20131211090204.GS11295@suse.de>
References: <1386723001-25408-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1386723001-25408-6-git-send-email-liwanp@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1386723001-25408-6-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Dec 11, 2013 at 08:49:58AM +0800, Wanpeng Li wrote:
> Use wrapper function task_faults_idx to calculate index in group_faults.
> 
> Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
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
