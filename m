Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id 3EA0B6B0035
	for <linux-mm@kvack.org>; Tue,  4 Feb 2014 03:40:53 -0500 (EST)
Received: by mail-ig0-f181.google.com with SMTP id j1so6816890iga.2
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 00:40:53 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id ih2si10586446icc.47.2014.02.04.00.40.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Feb 2014 00:40:50 -0800 (PST)
Date: Tue, 4 Feb 2014 09:39:19 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v4] oom: add tracepoints for oom_score_adj
Message-ID: <20140204083918.GA31442@dyad.arnhem.chello.nl>
References: <20111207095434.5f2fed4b.kamezawa.hiroyu@jp.fujitsu.com>
 <4EDF99B2.6040007@jp.fujitsu.com>
 <20111208104705.b2e50039.kamezawa.hiroyu@jp.fujitsu.com>
 <20111208153230.9c68eab3.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111208153230.9c68eab3.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, rientjes@google.com, dchinner@redhat.com

On Thu, Dec 08, 2011 at 03:32:30PM +0900, KAMEZAWA Hiroyuki wrote:
> From 5dc1f8c879ae424d5853af255df8860494209e39 Mon Sep 17 00:00:00 2001
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date: Wed, 7 Dec 2011 09:58:16 +0900
> Subject: [PATCH] oom: trace point for oom_score_adj
> 
> oom_score_adj is set to prevent a task from being killed by OOM-Killer.
> Some daemons sets this value and their children inerit it sometimes.
> Because inheritance of oom_score_adj is done automatically, users
> can be confused at seeing the value and finds it's hard to debug.
> 
> This patch adds trace point for oom_score_adj. This adds 3 trace
> points. at
> 	- update oom_score_adj
> 	- fork()
> 	- rename task->comm(typically, exec())
> 

And nobody was bothered by the fact that we already had fork and exec tracepoints?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
