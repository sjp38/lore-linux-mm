Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id B555C6B0002
	for <linux-mm@kvack.org>; Mon, 20 May 2013 18:31:43 -0400 (EDT)
Date: Mon, 20 May 2013 15:31:35 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: mmotm 2013-05-09-15-57 uploaded
Message-Id: <20130520153135.a47e21227a4fc3a77996b482@linux-foundation.org>
In-Reply-To: <CAFTL4hwvP7GsrNTc4knQRMV1YHXnZRes=E_NpLAKSOgqTeou5g@mail.gmail.com>
References: <20130509225833.C37A55A41D4@corp2gmr1-2.hot.corp.google.com>
	<CAFTL4hwvP7GsrNTc4knQRMV1YHXnZRes=E_NpLAKSOgqTeou5g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frederic Weisbecker <fweisbec@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

On Mon, 20 May 2013 11:42:09 +0200 Frederic Weisbecker <fweisbec@gmail.com> wrote:

> Hi Andrew,
> 
> 2013/5/10  <akpm@linux-foundation.org>:
> [...]
> > * posix_cpu_timer-consolidate-expiry-time-type.patch
> > * posix_cpu_timers-consolidate-timer-list-cleanups.patch
> > * posix_cpu_timers-consolidate-expired-timers-check.patch
> > * selftests-add-basic-posix-timers-selftests.patch
> > * posix-timers-correctly-get-dying-task-time-sample-in-posix_cpu_timer_schedule.patch
> > * posix_timers-fix-racy-timer-delta-caching-on-task-exit.patch
> 
> Do you have any plans concerning these patches? These seem to have
> missed this merge window.

They're in my queue of "stuff to send to tglx" when I do my next
maintainer patchbombing.

I guess I should have done that significantly before the 3.10 release,
but it's rather discouraging how few of those patches get applied by
anyone.  Maybe the solution to that is to send them more often, not
less.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
