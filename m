Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f41.google.com (mail-oa0-f41.google.com [209.85.219.41])
	by kanga.kvack.org (Postfix) with ESMTP id E2F056B0031
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 01:48:42 -0500 (EST)
Received: by mail-oa0-f41.google.com with SMTP id j17so8611571oag.0
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 22:48:42 -0800 (PST)
Received: from e28smtp06.in.ibm.com (e28smtp06.in.ibm.com. [122.248.162.6])
        by mx.google.com with ESMTPS id iz10si15399629obb.104.2013.12.11.22.48.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 11 Dec 2013 22:48:40 -0800 (PST)
Received: from /spool/local
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 12 Dec 2013 12:18:26 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 127EBE0024
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 12:20:43 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBC6mGUh60489768
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 12:18:16 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBC6mLKN019840
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 12:18:21 +0530
Date: Thu, 12 Dec 2013 14:48:19 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v7 1/4] sched/numa: drop
 sysctl_numa_balancing_settle_count sysctl
Message-ID: <52a95c48.aa71b60a.285d.ffffa06fSMTPIN_ADDED_BROKEN@mx.google.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1386807143-15994-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1386807143-15994-2-git-send-email-liwanp@linux.vnet.ibm.com>
 <alpine.DEB.2.02.1312112241080.11740@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1312112241080.11740@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Dec 11, 2013 at 10:41:47PM -0800, David Rientjes wrote:
>On Thu, 12 Dec 2013, Wanpeng Li wrote:
>
>> commit 887c290e (sched/numa: Decide whether to favour task or group weights
>> based on swap candidate relationships) drop the check against
>> sysctl_numa_balancing_settle_count, this patch remove the sysctl.
>> 
>
>What about the references to it in Documentation/sysctl/kernel.txt?

Ah, ok, I will fix it. Thanks.

Regards,
Wanpeng Li 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
