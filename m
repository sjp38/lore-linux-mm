Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id EEF9A6B00B9
	for <linux-mm@kvack.org>; Mon, 24 Nov 2014 12:01:25 -0500 (EST)
Received: by mail-wi0-f173.google.com with SMTP id r20so6354416wiv.12
        for <linux-mm@kvack.org>; Mon, 24 Nov 2014 09:01:25 -0800 (PST)
Received: from mail-wg0-x234.google.com (mail-wg0-x234.google.com. [2a00:1450:400c:c00::234])
        by mx.google.com with ESMTPS id x7si13230897wiw.14.2014.11.24.09.01.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 24 Nov 2014 09:01:25 -0800 (PST)
Received: by mail-wg0-f52.google.com with SMTP id a1so12802660wgh.39
        for <linux-mm@kvack.org>; Mon, 24 Nov 2014 09:01:25 -0800 (PST)
Date: Mon, 24 Nov 2014 18:01:22 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 3/5] mm: Remember ongoing memory allocation status.
Message-ID: <20141124170122.GC11745@curandero.mameluci.net>
References: <201411231349.CAG78628.VFQFOtOSFJMOLH@I-love.SAKURA.ne.jp>
 <201411231351.HJA17065.VHQSFOJFtLFOMO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201411231351.HJA17065.VHQSFOJFtLFOMO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org

On Sun 23-11-14 13:51:31, Tetsuo Handa wrote:
> >From 0c6d4e0ac9fc5964fdd09849c99e4f6497b7a37e Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Sun, 23 Nov 2014 13:40:20 +0900
> Subject: [PATCH 3/5] mm: Remember ongoing memory allocation status.
> 
> When a stall by memory allocation problem occurs, printing how long
> a thread was blocked for memory allocation will be useful.

Why tracepoints are not suitable for this debugging?

> This patch allows remembering how many jiffies was spent for ongoing
> __alloc_pages_nodemask() and reading it by printing backtrace and by
> analyzing vmcore.

__alloc_pages_nodemask is a hotpath of the allocation and it is not
really acceptable to add debugging stuff there which will have only very
limited usage.

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
