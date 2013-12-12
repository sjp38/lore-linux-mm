Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f54.google.com (mail-yh0-f54.google.com [209.85.213.54])
	by kanga.kvack.org (Postfix) with ESMTP id 8D8896B0031
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 01:48:44 -0500 (EST)
Received: by mail-yh0-f54.google.com with SMTP id z12so5994177yhz.13
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 22:48:44 -0800 (PST)
Received: from mail-yh0-x232.google.com (mail-yh0-x232.google.com [2607:f8b0:4002:c01::232])
        by mx.google.com with ESMTPS id v3si20779503yhd.63.2013.12.11.22.48.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 11 Dec 2013 22:48:43 -0800 (PST)
Received: by mail-yh0-f50.google.com with SMTP id b6so6066149yha.37
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 22:48:43 -0800 (PST)
Date: Wed, 11 Dec 2013 22:48:40 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v7 3/4] sched/numa: use wrapper function task_faults_idx
 to calculate index in group_faults
In-Reply-To: <1386807143-15994-4-git-send-email-liwanp@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.02.1312112247300.11740@chino.kir.corp.google.com>
References: <1386807143-15994-1-git-send-email-liwanp@linux.vnet.ibm.com> <1386807143-15994-4-git-send-email-liwanp@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 12 Dec 2013, Wanpeng Li wrote:

> Use wrapper function task_faults_idx to calculate index in group_faults.
> 
> Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Acked-by: Mel Gorman <mgorman@suse.de>
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

Acked-by: David Rientjes <rientjes@google.com>

The naming of task_faults_idx() is a little unfortunate since it is now 
used to index into both task_faults() and group_faults(), though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
