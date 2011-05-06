Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id CDB066B0024
	for <linux-mm@kvack.org>; Fri,  6 May 2011 18:49:10 -0400 (EDT)
Received: from hpaq11.eem.corp.google.com (hpaq11.eem.corp.google.com [172.25.149.11])
	by smtp-out.google.com with ESMTP id p46Mn6L5029908
	for <linux-mm@kvack.org>; Fri, 6 May 2011 15:49:07 -0700
Received: from pxi9 (pxi9.prod.google.com [10.243.27.9])
	by hpaq11.eem.corp.google.com with ESMTP id p46Mmwkm022700
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 6 May 2011 15:49:05 -0700
Received: by pxi9 with SMTP id 9so6707173pxi.28
        for <linux-mm@kvack.org>; Fri, 06 May 2011 15:49:00 -0700 (PDT)
Date: Fri, 6 May 2011 15:48:58 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [Question] how to detect mm leaker and kill?
In-Reply-To: <BANLkTi=S_gSvnQimgqrMmq9eWJYDCDRVmA@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1105061547150.2451@chino.kir.corp.google.com>
References: <BANLkTi=S_gSvnQimgqrMmq9eWJYDCDRVmA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Yong Zhang <yong.zhang0@gmail.com>

On Fri, 6 May 2011, Hillf Danton wrote:

> Hi
> 
> In the scenario that 2GB  physical RAM is available, and there is a
> database application that eats 1.4GB RAM without leakage already
> running, another leaker who leaks 4KB an hour is also running, could
> the leaker be detected and killed in mm/oom_kill.c with default
> configure when oom happens?
> 

Yes, if you know the database application is going to use 70% of your 
system RAM and you wish to discount that from its memory use when being 
considered for oom kill, set its /proc/pid/oom_score_adj to -700.

This is only possible on 2.6.36 and later kernels when oom_score_adj was 
introduced.

If you'd like to completely disable oom killing, set 
/proc/pid/oom_score_adj to -1000.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
