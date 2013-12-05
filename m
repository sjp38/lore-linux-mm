Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 536456B0031
	for <linux-mm@kvack.org>; Thu,  5 Dec 2013 07:27:50 -0500 (EST)
Received: by mail-wi0-f169.google.com with SMTP id hn6so771026wib.4
        for <linux-mm@kvack.org>; Thu, 05 Dec 2013 04:27:49 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id t9si980153wiv.72.2013.12.05.04.27.49
        for <linux-mm@kvack.org>;
        Thu, 05 Dec 2013 04:27:49 -0800 (PST)
Message-ID: <52A07126.70508@redhat.com>
Date: Thu, 05 Dec 2013 07:27:18 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] sched/numa: drop idx field of task_numa_env struct
References: <1386241817-5051-1-git-send-email-liwanp@linux.vnet.ibm.com> <1386241817-5051-2-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1386241817-5051-2-git-send-email-liwanp@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 12/05/2013 06:10 AM, Wanpeng Li wrote:
> Drop unused idx field of task_numa_env struct.
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
