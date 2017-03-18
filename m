Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 36AA06B0398
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 21:30:55 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id y6so134830011pfa.3
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 18:30:55 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 34si10234099plz.66.2017.03.17.18.30.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 17 Mar 2017 18:30:54 -0700 (PDT)
Subject: Re: DOM Worker: page allocation stalls (4.9.13)
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170316100409.GR802@shells.gnugeneration.com>
	<20170317084652.GD26298@dhcp22.suse.cz>
	<08ae9fca-9388-1f8a-f8ae-14ada0bdbb92@I-love.SAKURA.ne.jp>
	<20170317135440.GJ26298@dhcp22.suse.cz>
In-Reply-To: <20170317135440.GJ26298@dhcp22.suse.cz>
Message-Id: <201703181030.DII52105.FOQSVHFOFMOLJt@I-love.SAKURA.ne.jp>
Date: Sat, 18 Mar 2017 10:30:46 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: elektron@halo.nu, linux-mm@kvack.org

Michal Hocko wrote:
> > If you can rebuild your kernel, calling dump_tasks() in mm/oom_kill.c when
> > you hit warn_alloc() warnings might help.
> 
> I do not really see how this would help much. If anything watching for
> /proc/vmstat counters would tell us much more.

Under memory pressure, read()/write() syscalls might involve significant delay
(including reading from /sys/kernel/debug/tracing/trace_pipe and writing to
a log file). Unless all problems are contained in a cgroup (which means that
administrators can diagnose from outside of that cgroup), it is silly to try to
read memory related information of a stalling system using userspace interface.

Therefore, automatic printk() is helpful than trying to start "cat /proc/vmstat"
 from a shell. I wish there is a kernel function which does
"cat /proc/some_file" and/or "cat /sys/kernel/debug/tracing/trace_pipe" and
sends the output to printk() so that such actions will not involve significant
delay under memory pressure.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
