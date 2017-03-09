Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0643C2808E3
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 17:37:54 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id f21so134238706pgi.4
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 14:37:53 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id s15si7714272plj.27.2017.03.09.14.37.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Mar 2017 14:37:53 -0800 (PST)
Date: Thu, 9 Mar 2017 14:37:51 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v7] mm: Add memory allocation watchdog kernel thread.
Message-Id: <20170309143751.05bddcbad82672384947de5f@linux-foundation.org>
In-Reply-To: <201703091946.GDC21885.OQFFOtJHSOFVML@I-love.SAKURA.ne.jp>
References: <1488244908-57586-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<201703091946.GDC21885.OQFFOtJHSOFVML@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@kernel.org, hannes@cmpxchg.org, mgorman@techsingularity.net, david@fromorbit.com, apolyakov@beget.ru

On Thu, 9 Mar 2017 19:46:14 +0900 Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> wrote:

> Tetsuo Handa wrote:
> > This patch adds a watchdog which periodically reports number of memory
> > allocating tasks, dying tasks and OOM victim tasks when some task is
> > spending too long time inside __alloc_pages_slowpath(). This patch also
> > serves as a hook for obtaining additional information using SystemTap
> > (e.g. examine other variables using printk(), capture a crash dump by
> > calling panic()) by triggering a callback only when a stall is detected.
> > Ability to take administrator-controlled actions based on some threshold
> > is a big advantage gained by introducing a state tracking.
> > 
> > Commit 63f53dea0c9866e9 ("mm: warn about allocations which stall for
> > too long") was a great step for reducing possibility of silent hang up
> > problem caused by memory allocation stalls [1]. However, there are
> > reports of long stalls (e.g. [2] is over 30 minutes!) and lockups (e.g.
> > [3] is an "unable to invoke the OOM killer due to !__GFP_FS allocation"
> > lockup problem) where this patch is more useful than that commit, for
> > this patch can report possibly related tasks even if allocating tasks
> > are unexpectedly blocked for so long. Regarding premature OOM killer
> > invocation, tracepoints which can accumulate samples in short interval
> > would be useful. But regarding too late to report allocation stalls,
> > this patch which can capture all tasks (for reporting overall situation)
> > in longer interval and act as a trigger (for accumulating short interval
> > samples) would be useful.
)
> Andrew, do you have any questions on this patch?
> I really need this patch for finding bugs which MM people overlook.

(top-posting repaired - please don't do that)

Undecided.  I can see the need but it is indeed quite a large lump of
code.  Perhaps some additional examples of how this new code was used
to understand and improve real-world kernel problems would be persuasive.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
