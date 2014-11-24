Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 2A63B6B00B6
	for <linux-mm@kvack.org>; Mon, 24 Nov 2014 12:20:03 -0500 (EST)
Received: by mail-wi0-f180.google.com with SMTP id n3so6616617wiv.1
        for <linux-mm@kvack.org>; Mon, 24 Nov 2014 09:20:02 -0800 (PST)
Received: from mail-wg0-x229.google.com (mail-wg0-x229.google.com. [2a00:1450:400c:c00::229])
        by mx.google.com with ESMTPS id ge2si13041414wib.95.2014.11.24.09.20.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 24 Nov 2014 09:20:01 -0800 (PST)
Received: by mail-wg0-f41.google.com with SMTP id y19so12799832wgg.14
        for <linux-mm@kvack.org>; Mon, 24 Nov 2014 09:20:00 -0800 (PST)
Date: Mon, 24 Nov 2014 18:19:57 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 5/5] mm: Insert some delay if ongoing memory allocation
 stalls.
Message-ID: <20141124171956.GE11745@curandero.mameluci.net>
References: <201411231349.CAG78628.VFQFOtOSFJMOLH@I-love.SAKURA.ne.jp>
 <201411231353.BDE90173.FQOMJtHOLVFOFS@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201411231353.BDE90173.FQOMJtHOLVFOFS@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org

On Sun 23-11-14 13:53:41, Tetsuo Handa wrote:
> >From 4fad86f7a653dbbaec3ba2389f74f97a6705a558 Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Sun, 23 Nov 2014 13:41:24 +0900
> Subject: [PATCH 5/5] mm: Insert some delay if ongoing memory allocation stalls.
> 
> This patch introduces 1ms of unkillable sleep before retrying when
> sleepable __alloc_pages_nodemask() is taking more than 5 seconds.
> According to Documentation/timers/timers-howto.txt, msleep < 20ms
> can sleep for up to 20ms, but this should not be a problem because
> msleep(1) is called only when there is no choice but retrying.
> 
> This patch is intended for two purposes.
> 
> (1) Reduce CPU usage when memory allocation deadlock occurred, by
>     avoiding useless busy retry loop.
> 
> (2) Allow SysRq-w (or SysRq-t) to report how long each thread is
>     blocked for memory allocation.

Both do not make any sense to me whatsoever. If there is a deadlock then
we cannot consume CPU as the deadlocked tasks are _blocked_. I guess you
meant livelocked but even then, how does a random timeout helps?

Why would a timeout help sysrq to proceed?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
