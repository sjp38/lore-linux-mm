Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f47.google.com (mail-ee0-f47.google.com [74.125.83.47])
	by kanga.kvack.org (Postfix) with ESMTP id 9EE5C6B0036
	for <linux-mm@kvack.org>; Sat,  7 Dec 2013 22:14:38 -0500 (EST)
Received: by mail-ee0-f47.google.com with SMTP id e51so933718eek.20
        for <linux-mm@kvack.org>; Sat, 07 Dec 2013 19:14:38 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id s42si4027692eew.224.2013.12.07.19.14.34
        for <linux-mm@kvack.org>;
        Sat, 07 Dec 2013 19:14:35 -0800 (PST)
Message-ID: <52A3E400.2010503@redhat.com>
Date: Sat, 07 Dec 2013 22:14:08 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 6/6] sched/numa: make numamigrate_update_ratelimit
 static
References: <1386321136-27538-1-git-send-email-liwanp@linux.vnet.ibm.com> <1386321136-27538-6-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1386321136-27538-6-git-send-email-liwanp@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 12/06/2013 04:12 AM, Wanpeng Li wrote:
> Make numamigrate_update_ratelimit static.
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
