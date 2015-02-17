Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id C8B106B0072
	for <linux-mm@kvack.org>; Tue, 17 Feb 2015 07:52:50 -0500 (EST)
Received: by pdjy10 with SMTP id y10so43540310pdj.6
        for <linux-mm@kvack.org>; Tue, 17 Feb 2015 04:52:50 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id rp16si17292953pab.7.2015.02.17.04.52.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 17 Feb 2015 04:52:49 -0800 (PST)
Subject: Re: How to handle TIF_MEMDIE stalls?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20141229181937.GE32618@dhcp22.suse.cz>
	<201412301542.JEC35987.FFJFOOQtHLSMVO@I-love.SAKURA.ne.jp>
	<20141230112158.GA15546@dhcp22.suse.cz>
	<201502162023.GGE26089.tJOOFQMFFHLOVS@I-love.SAKURA.ne.jp>
	<20150216154201.GA27295@phnom.home.cmpxchg.org>
In-Reply-To: <20150216154201.GA27295@phnom.home.cmpxchg.org>
Message-Id: <201502172057.GCD09362.FtHQMVSLJOFFOO@I-love.SAKURA.ne.jp>
Date: Tue, 17 Feb 2015 20:57:05 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org
Cc: mhocko@suse.cz, david@fromorbit.com, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org

Johannes Weiner wrote:
> On Mon, Feb 16, 2015 at 08:23:16PM +0900, Tetsuo Handa wrote:
> >   (2) Implement TIF_MEMDIE timeout.
> 
> How about something like this?  This should solve the deadlock problem
> in the page allocator, but it would also simplify the memcg OOM killer
> and allow its use by in-kernel faults again.

Yes, basic idea would be same with
http://marc.info/?l=linux-mm&m=142002495532320&w=2 .

But Michal and David do not like the timeout approach.
http://marc.info/?l=linux-mm&m=141684783713564&w=2
http://marc.info/?l=linux-mm&m=141686814824684&w=2

Unless they change their opinion in response to the discovery explained at
http://lwn.net/Articles/627419/ , timeout patches will not be accepted.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
