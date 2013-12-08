Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 77C746B0036
	for <linux-mm@kvack.org>; Sat,  7 Dec 2013 19:06:46 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id v10so3016458pde.41
        for <linux-mm@kvack.org>; Sat, 07 Dec 2013 16:06:46 -0800 (PST)
Received: from e23smtp01.au.ibm.com (e23smtp01.au.ibm.com. [202.81.31.143])
        by mx.google.com with ESMTPS id v7si2704720pbi.248.2013.12.07.16.06.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 07 Dec 2013 16:06:45 -0800 (PST)
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Sun, 8 Dec 2013 10:06:42 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id BDB2D2CE8040
	for <linux-mm@kvack.org>; Sun,  8 Dec 2013 11:06:38 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rB7NmTcG62128142
	for <linux-mm@kvack.org>; Sun, 8 Dec 2013 10:48:30 +1100
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rB806aLc001712
	for <linux-mm@kvack.org>; Sun, 8 Dec 2013 11:06:37 +1100
Date: Sun, 8 Dec 2013 08:06:35 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 1/6] sched/numa: fix set cpupid on page migration twice
Message-ID: <52a3b815.0722440a.12b6.54a1SMTPIN_ADDED_BROKEN@mx.google.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1386321136-27538-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <20131206165623.GR11295@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131206165623.GR11295@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Dec 06, 2013 at 04:56:23PM +0000, Mel Gorman wrote:
>On Fri, Dec 06, 2013 at 05:12:11PM +0800, Wanpeng Li wrote:
>> commit 7851a45cd3 (mm: numa: Copy cpupid on page migration) copy over 
>> the cpupid at page migration time, there is unnecessary to set it again 
>> in migrate_misplaced_transhuge_page, this patch fix it.
>> 
>> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>
>Acked-by: Mel Gorman <mgorman@suse.de>
>

Thanks for your review, Mel. ;-)

Regards,
Wanpeng Li 

>-- 
>Mel Gorman
>SUSE Labs
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
