Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 584838299B
	for <linux-mm@kvack.org>; Fri, 13 Mar 2015 10:52:54 -0400 (EDT)
Received: by wggy19 with SMTP id y19so23780069wgg.9
        for <linux-mm@kvack.org>; Fri, 13 Mar 2015 07:52:54 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id gz6si3402894wjc.142.2015.03.13.07.52.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Mar 2015 07:52:52 -0700 (PDT)
Message-ID: <5502F9BC.2020001@redhat.com>
Date: Fri, 13 Mar 2015 10:52:44 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: kswapd hogging in lowmem_shrink
References: <CAB5gotvwyD74UugjB6XQ_v=o11Hu9wAuA6N94UvGObPARYEz0w@mail.gmail.com>
In-Reply-To: <CAB5gotvwyD74UugjB6XQ_v=o11Hu9wAuA6N94UvGObPARYEz0w@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vaibhav Shinde <v.bhav.shinde@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>

On 03/13/2015 10:25 AM, Vaibhav Shinde wrote:
> 
> On low memory situation, I see various shrinkers being invoked, but in
> lowmem_shrink() case, kswapd is found to be hogging for around 150msecs.
> 
> Due to this my application suffer latency issue, as the cpu was not
> released by kswapd0.
> 
> I took below traces with vmscan events, that show lowmem_shrink taking
> such long time for execution.

This is the Android low memory killer, which kills the
task with the lowest priority in the system.

The low memory killer will iterate over all the tasks
in the system to identify the task to kill.

This is not a problem in Android systems, and other
small systems where this piece of code is used.

What kind of system are you trying to use the low
memory killer on?

How many tasks are you running?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
