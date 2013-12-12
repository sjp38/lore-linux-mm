Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f42.google.com (mail-yh0-f42.google.com [209.85.213.42])
	by kanga.kvack.org (Postfix) with ESMTP id 43D786B0031
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 01:44:11 -0500 (EST)
Received: by mail-yh0-f42.google.com with SMTP id z6so6054985yhz.1
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 22:44:11 -0800 (PST)
Received: from mail-yh0-x235.google.com (mail-yh0-x235.google.com [2607:f8b0:4002:c01::235])
        by mx.google.com with ESMTPS id q66si15624896yhm.104.2013.12.11.22.44.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 11 Dec 2013 22:44:10 -0800 (PST)
Received: by mail-yh0-f53.google.com with SMTP id b20so5872227yha.26
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 22:44:10 -0800 (PST)
Date: Wed, 11 Dec 2013 22:44:07 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v7 2/4] sched/numa: use wrapper function task_node to
 get node which task is on
In-Reply-To: <1386807143-15994-3-git-send-email-liwanp@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.02.1312112243550.11740@chino.kir.corp.google.com>
References: <1386807143-15994-1-git-send-email-liwanp@linux.vnet.ibm.com> <1386807143-15994-3-git-send-email-liwanp@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 12 Dec 2013, Wanpeng Li wrote:

> Changelog:
>  v2 -> v3:
>   * tranlate cpu_to_node(task_cpu(p)) to task_node(p) in sched/debug.c
> 
> Use wrapper function task_node to get node which task is on.
> 
> Acked-by: Mel Gorman <mgorman@suse.de>
> Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Reviewed-by: Rik van Riel <riel@redhat.com>
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
