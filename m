Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3616C6B0007
	for <linux-mm@kvack.org>; Tue, 20 Mar 2018 16:46:54 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id g22so1434502pgv.16
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 13:46:54 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id p9sor716467pgd.305.2018.03.20.13.46.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 20 Mar 2018 13:46:53 -0700 (PDT)
Date: Tue, 20 Mar 2018 13:46:51 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2] mm,oom_reaper: Show trace of unable to reap victim
 thread.
In-Reply-To: <201803202320.IDG60953.QOFOFVFSLOHtMJ@I-love.SAKURA.ne.jp>
Message-ID: <alpine.DEB.2.20.1803201341210.167205@chino.kir.corp.google.com>
References: <20180320131953.GM23100@dhcp22.suse.cz> <201803202230.HDH17140.OFtMQJVLOOFHSF@I-love.SAKURA.ne.jp> <20180320133445.GP23100@dhcp22.suse.cz> <201803202250.CHG18290.FJMOtOHLFVQFOS@I-love.SAKURA.ne.jp> <20180320141051.GS23100@dhcp22.suse.cz>
 <201803202320.IDG60953.QOFOFVFSLOHtMJ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: mhocko@suse.com, linux-mm@kvack.org

On Tue, 20 Mar 2018, Tetsuo Handa wrote:

> > I am no questioning that. I am questioning the additional information
> > because we won't be able to do anything about mmap_sem holder most of
> > the time. Because they tend block on allocations...
> 
> serial-20180320.txt.xz is saying that they tend to block on i_mmap_lock_write() rather
> than memory allocations. Making memory allocations killable will need a lot of work.
> But I think that making frequently hitting down_write() killable won't need so much work.
> 

I have available to me more than 28,222,058 occurrences of successful oom 
reaping and 13,018 occurrences of failing to grab mm->mmap_sem.

The number of failures is low on production workloads, so I don't see an 
issue with emitting a stack trace in these instances if it can help 
improve things.  But for my 0.04% failure rate, I can't say that I would 
look into them much unless it results in the system livelocking.  Unless 
there's a compelling reason why this is shouldn't be done (too much email 
sent to linux-mm as a result? :), I say just go ahead and add the darn 
stack trace.
