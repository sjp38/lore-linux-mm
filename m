Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 84E736B005A
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 12:04:27 -0400 (EDT)
Date: Fri, 19 Oct 2012 18:04:25 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: process hangs on do_exit when oom happens
Message-ID: <20121019160425.GA10175@dhcp22.suse.cz>
References: <op.wmbi5kbrn27o5l@gaoqiang-d1.corp.qihoo.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <op.wmbi5kbrn27o5l@gaoqiang-d1.corp.qihoo.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gaoqiang <gaoqiangscut@gmail.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mmc@vger.kernel.org" <linux-mmc@vger.kernel.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, linux-mm@kvack.org

On Wed 17-10-12 18:23:34, gaoqiang wrote:
> I looked up nothing useful with google,so I'm here for help..
> 
> when this happens:  I use memcg to limit the memory use of a
> process,and when the memcg cgroup was out of memory,
> the process was oom-killed   however,it cannot really complete the
> exiting. here is the some information

How many tasks are in the group and what kind of memory do they use?
Is it possible that you were hit by the same issue as described in 
79dfdacc memcg: make oom_lock 0 and 1 based rather than counter.

> OS version:  centos6.2    2.6.32.220.7.1

Your kernel is quite old and you should be probably asking your
distribution to help you out. There were many fixes since 2.6.32.
Are you able to reproduce the same issue with the current vanila kernel?

> /proc/pid/stack
> ---------------------------------------------------------------
> 
> [<ffffffff810597ca>] __cond_resched+0x2a/0x40
> [<ffffffff81121569>] unmap_vmas+0xb49/0xb70
> [<ffffffff8112822e>] exit_mmap+0x7e/0x140
> [<ffffffff8105b078>] mmput+0x58/0x110
> [<ffffffff81061aad>] exit_mm+0x11d/0x160
> [<ffffffff81061c9d>] do_exit+0x1ad/0x860
> [<ffffffff81062391>] do_group_exit+0x41/0xb0
> [<ffffffff81077cd8>] get_signal_to_deliver+0x1e8/0x430
> [<ffffffff8100a4c4>] do_notify_resume+0xf4/0x8b0
> [<ffffffff8100b281>] int_signal+0x12/0x17
> [<ffffffffffffffff>] 0xffffffffffffffff

This looks strange because this is just an exit part which shouldn't
deadlock or anything. Is this stack stable? Have you tried to take check
it more times?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
