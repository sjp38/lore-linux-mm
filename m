Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 15E0E6B01F7
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 02:39:06 -0400 (EDT)
Message-ID: <4BC6B4B3.8070000@cn.fujitsu.com>
Date: Thu, 15 Apr 2010 14:39:47 +0800
From: Miao Xie <miaox@cn.fujitsu.com>
Reply-To: miaox@cn.fujitsu.com
MIME-Version: 1.0
Subject: Re: Lockdep splat in cpuset code acquiring alloc_lock
References: <20100414202347.GA26791@linux.vnet.ibm.com> <z2m6599ad831004141410tdc40feb0h529dabe4a39d67d5@mail.gmail.com>
In-Reply-To: <z2m6599ad831004141410tdc40feb0h529dabe4a39d67d5@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Paul Menage <menage@google.com>
Cc: paulmck@linux.vnet.ibm.com, Rusty Russell <rusty@rustcorp.com.au>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.linux-foundation.org, balbir@linux.vnet.ibm.com, lizf@cn.fujitsu.com, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

CC Oleg
CC Ingo

on 2010-4-15 5:10, Paul Menage wrote:
> Looks like select_fallback_rq() shouldn't be calling
> cpuset_cpus_allowed_locked(), which does a task_lock(), which isn't
> IRQ safe. Also, according to its comments that should only be held
> with the cpuset callback_mutex held, which seems unlikely from a
> softirq handler.
> 
> Also, calling cpuset_cpus_allowed_locked(p, &p->cpus_allowed) stomps
> on state in p without (AFAICS) synchronization.
> 
> The description of commit e76bd8d9850c2296a7e8e24c9dce9b5e6b55fe2f
> includes the phrase " I'm fairly sure this works, but there might be a
> deadlock hiding" although I think that the lockdep-reported problem is
> different than what Rusty had in mind.

This problem have been fixed by Oleg Nesterov, and the patchset was merged
into tip tree, but it's scheduled for .35 ...

http://lkml.org/lkml/2010/3/15/73

Thanks!
Miao

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
