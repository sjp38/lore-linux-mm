Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id CA0186B0087
	for <linux-mm@kvack.org>; Wed, 10 Nov 2010 11:01:38 -0500 (EST)
Date: Wed, 10 Nov 2010 16:55:30 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: INFO: suspicious rcu_dereference_check() usage -
	kernel/pid.c:419 invoked rcu_dereference_check() without protection!
Message-ID: <20101110155530.GA1905@redhat.com>
References: <xr93fwwbdh1d.fsf@ninji.mtv.corp.google.com> <20101107182028.GZ15561@linux.vnet.ibm.com> <20101108151509.GA3702@redhat.com> <20101109202900.GV4032@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101109202900.GV4032@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Jens Axboe <jens.axboe@oracle.com>
List-ID: <linux-mm.kvack.org>

On 11/09, Paul E. McKenney wrote:
>
> Thank you, Oleg!  Greg, would you be willing to update your patch
> to remove the comment?  (Perhaps tasklist_lock as well...)

Agreed, I think tasklock should be killed.


But wait. Whatever we do, isn't this code racy? I do not see why, say,
sys_ioprio_set(IOPRIO_WHO_PROCESS) can't install ->io_context after
this task has already passed exit_io_context().

Jens, am I missed something?

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
