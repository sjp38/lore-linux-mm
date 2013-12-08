Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 6A5596B0035
	for <linux-mm@kvack.org>; Sat,  7 Dec 2013 20:19:55 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id p10so3087171pdj.4
        for <linux-mm@kvack.org>; Sat, 07 Dec 2013 17:19:54 -0800 (PST)
Received: from e28smtp03.in.ibm.com (e28smtp03.in.ibm.com. [122.248.162.3])
        by mx.google.com with ESMTPS id sl10si2837542pab.99.2013.12.07.17.19.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 07 Dec 2013 17:19:53 -0800 (PST)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Sun, 8 Dec 2013 06:49:49 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id B62CD1258055
	for <linux-mm@kvack.org>; Sun,  8 Dec 2013 06:50:53 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rB81JawE42926194
	for <linux-mm@kvack.org>; Sun, 8 Dec 2013 06:49:37 +0530
Received: from d28av03.in.ibm.com (localhost [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rB81Jj3l017554
	for <linux-mm@kvack.org>; Sun, 8 Dec 2013 06:49:45 +0530
Date: Sun, 8 Dec 2013 09:19:44 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 1/6] sched/numa: fix set cpupid on page migration twice
Message-ID: <52a3c939.6a90420a.5ed9.72b1SMTPIN_ADDED_BROKEN@mx.google.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1386321136-27538-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <52A3C75A.1030605@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52A3C75A.1030605@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, Dec 07, 2013 at 08:11:54PM -0500, Rik van Riel wrote:
>On 12/06/2013 04:12 AM, Wanpeng Li wrote:
>> commit 7851a45cd3 (mm: numa: Copy cpupid on page migration) copy over 
>> the cpupid at page migration time, there is unnecessary to set it again 
>> in migrate_misplaced_transhuge_page, this patch fix it.
>> 
>> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>
>Reviewed-by: Rik van Riel <riel@redhat.com>

Thanks for your review, Rik. ;-)

Regards,
Wanpeng Li 

>
>-- 
>All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
