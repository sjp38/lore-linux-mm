Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 9C0966B0023
	for <linux-mm@kvack.org>; Wed, 18 May 2011 09:01:22 -0400 (EDT)
Date: Wed, 18 May 2011 15:00:04 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v2 1/3] coredump: use get_task_comm for %e filename
	format
Message-ID: <20110518130004.GA10638@redhat.com>
References: <1305181093-20871-1-git-send-email-jslaby@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1305181093-20871-1-git-send-email-jslaby@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Slaby <jslaby@suse.cz>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, jirislaby@gmail.com, Alan Cox <alan@lxorguk.ukuu.org.uk>, Al Viro <viro@zeniv.linux.org.uk>, Andi Kleen <andi@firstfloor.org>

Sorry for delay,

On 05/12, Jiri Slaby wrote:
>
> We currently access current->comm directly. As we have
> prctl(PR_SET_NAME), we need the access be protected by task_lock. This
> is exactly what get_task_comm does, so use it.
>
> I'm not 100% convinced prctl(PR_SET_NAME) may be called at the time of
> core dump,

It can't be called. Apart from current, a sub-thread can change ->comm[]
via /proc/pid/comm, but we already killed all threads.

> but the locking won't hurt.

Agreed, the patch looks correct. but still unneeded.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
