Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 8EA1A6B0023
	for <linux-mm@kvack.org>; Wed, 11 May 2011 13:37:16 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 2/3] printk: Add %ptc to safely print a task's comm
References: <1305073386-4810-1-git-send-email-john.stultz@linaro.org>
	<1305073386-4810-3-git-send-email-john.stultz@linaro.org>
Date: Wed, 11 May 2011 10:36:54 -0700
In-Reply-To: <1305073386-4810-3-git-send-email-john.stultz@linaro.org> (John
	Stultz's message of "Tue, 10 May 2011 17:23:05 -0700")
Message-ID: <m2sjsli1ft.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Ted Ts'o <tytso@mit.edu>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

John Stultz <john.stultz@linaro.org> writes:

> Acessing task->comm requires proper locking. However in the past
> access to current->comm could be done without locking. This
> is no longer the case, so all comm access needs to be done
> while holding the comm_lock.
>
> In my attempt to clean up unprotected comm access, I've noticed
> most comm access is done for printk output. To simpify correct
> locking in these cases, I've introduced a new %ptc format,
> which will safely print the corresponding task's comm.
>
> Example use:
> printk("%ptc: unaligned epc - sending SIGBUS.\n", current);

Neat. But you probably want a checkpatch rule for this too
to catch new offenders.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
