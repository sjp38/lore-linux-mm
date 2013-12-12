Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id 959F06B0031
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 19:14:15 -0500 (EST)
Received: by mail-pb0-f48.google.com with SMTP id md12so10970549pbc.35
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 16:14:15 -0800 (PST)
Received: from e28smtp03.in.ibm.com (e28smtp03.in.ibm.com. [122.248.162.3])
        by mx.google.com with ESMTPS id q8si14884141pav.289.2013.12.11.16.14.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 11 Dec 2013 16:14:14 -0800 (PST)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 12 Dec 2013 05:44:11 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 78484E0024
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 05:46:29 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBC0E6Hh6685100
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 05:44:06 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBC0E8iA028698
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 05:44:09 +0530
Date: Thu, 12 Dec 2013 08:14:07 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v6 0/6] mm: sched: numa: several fixups
Message-ID: <52a8ffd6.284a420a.452e.3d7aSMTPIN_ADDED_BROKEN@mx.google.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1386756961-3887-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <20131211102408.GI13532@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131211102408.GI13532@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Peter,
On Wed, Dec 11, 2013 at 11:24:08AM +0100, Peter Zijlstra wrote:
>On Wed, Dec 11, 2013 at 06:15:55PM +0800, Wanpeng Li wrote:
>> Hi Andrew,
>
>You'll find kernel/sched/ has a maintainer !Andrew.
>

I send out sched part to Ingo and you since Andrew has already pick up the
mm part. ;-)

Regards,
Wanpeng Li 

>>  include/linux/sched/sysctl.h |    1 -
>>  kernel/sched/debug.c         |    2 +-
>>  kernel/sched/fair.c          |   17 ++++-------------
>>  kernel/sysctl.c              |    7 -------
>>  mm/migrate.c                 |    4 ----
>>  5 files changed, 5 insertions(+), 26 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
