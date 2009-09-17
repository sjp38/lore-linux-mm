Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 4817A6B0055
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 16:36:50 -0400 (EDT)
Date: Thu, 17 Sep 2009 22:32:48 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: do_wait() changes && 2.6.32 -mm merge plans
Message-ID: <20090917203248.GB29346@redhat.com>
References: <20090915161535.db0a6904.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090915161535.db0a6904.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Roland McGrath <roland@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On 09/15, Andrew Morton wrote:
>
> ptrace-__ptrace_detach-do-__wake_up_parent-if-we-reap-the-tracee.patch
> do_wait-wakeup-optimization-shift-security_task_wait-from-eligible_child-to-wait_consider_task.patch
> #do_wait-wakeup-optimization-change-__wake_up_parent-to-use-filtered-wakeup.patch: busted (KAMEZAWA)
> do_wait-wakeup-optimization-change-__wake_up_parent-to-use-filtered-wakeup.patch

Hopefully the problem with this one is fixed, thanks again to Kamezawa.

> do_wait-wakeup-optimization-change-__wake_up_parent-to-use-filtered-wakeup-selinux_bprm_committed_creds-use-__wake_up_parent.patch
> do_wait-wakeup-optimization-child_wait_callback-check-__wnothread-case.patch
> do_wait-wakeup-optimization-fix-child_wait_callback-eligible_child-usage.patch
> do_wait-wakeup-optimization-simplify-task_pid_type.patch
> #do_wait-optimization-do-not-place-sub-threads-on-task_struct-children-list.patch: risky?
> do_wait-optimization-do-not-place-sub-threads-on-task_struct-children-list.patch

Yes, risky... God knows who can do list_for_each(->children) and expect to
find the sub-threads. But this is obviously good optimization/simplification.

It is just ugly to place sub-threads on ->children list, this buys nothing
but slown downs do_wait(). (this was needed, afaics, to handle ptraced but
not re-parented threads a long ago).

> wait_consider_task-kill-parent-argument.patch
> do_wait-fix-sys_waitid-specific-behaviour.patch
> wait_noreap_copyout-check-for-wo_info-=-null.patch
>
>   ptrace.  Mostly-merge.

Only the first patch is "ptrace" ;)

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
