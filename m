Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 8A9826B0035
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 05:29:04 -0500 (EST)
Received: by mail-pd0-f172.google.com with SMTP id g10so9294845pdj.3
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 02:29:04 -0800 (PST)
Received: from e23smtp07.au.ibm.com (e23smtp07.au.ibm.com. [202.81.31.140])
        by mx.google.com with ESMTPS id fn9si13162526pab.145.2013.12.11.02.29.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 11 Dec 2013 02:29:03 -0800 (PST)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 11 Dec 2013 20:29:00 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 9897C3578023
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 21:28:57 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBBAAjiH4850040
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 21:10:45 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBBASufM032193
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 21:28:56 +1100
Date: Wed, 11 Dec 2013 18:28:54 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v6 0/6] mm: sched: numa: several fixups
Message-ID: <52a83e6f.6966420a.0139.131bSMTPIN_ADDED_BROKEN@mx.google.com>
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

On Wed, Dec 11, 2013 at 11:24:08AM +0100, Peter Zijlstra wrote:
>On Wed, Dec 11, 2013 at 06:15:55PM +0800, Wanpeng Li wrote:
>> Hi Andrew,
>
>You'll find kernel/sched/ has a maintainer !Andrew.
>

Ah, ok. ;-)

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
