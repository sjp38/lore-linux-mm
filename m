Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 7BF0D6B0012
	for <linux-mm@kvack.org>; Wed, 11 May 2011 05:33:37 -0400 (EDT)
Received: by iyh42 with SMTP id 42so256664iyh.14
        for <linux-mm@kvack.org>; Wed, 11 May 2011 02:33:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1305073386-4810-3-git-send-email-john.stultz@linaro.org>
References: <1305073386-4810-1-git-send-email-john.stultz@linaro.org>
	<1305073386-4810-3-git-send-email-john.stultz@linaro.org>
Date: Wed, 11 May 2011 17:33:34 +0800
Message-ID: <BANLkTikXyqddLbQKyDYFrAwq9DamDj--AQ@mail.gmail.com>
Subject: Re: [PATCH 2/3] printk: Add %ptc to safely print a task's comm
From: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Ted Ts'o <tytso@mit.edu>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Wed, May 11, 2011 at 8:23 AM, John Stultz <john.stultz@linaro.org> wrote:
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
>

Why do you hide current->comm behide printk?
How is this better than printk("%s: ....", task_comm(current)) ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
