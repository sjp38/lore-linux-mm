Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id CDFA66B0023
	for <linux-mm@kvack.org>; Mon, 16 May 2011 19:56:42 -0400 (EDT)
Subject: Re: [PATCH 2/3] printk: Add %ptc to safely print a task's comm
From: Joe Perches <joe@perches.com>
In-Reply-To: <1305587432.2915.57.camel@work-vm>
References: <1305580757-13175-1-git-send-email-john.stultz@linaro.org>
	 <1305580757-13175-3-git-send-email-john.stultz@linaro.org>
	 <4DD19D10.3000201@gmail.com>  <1305587432.2915.57.camel@work-vm>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 16 May 2011 16:56:40 -0700
Message-ID: <1305590200.2503.48.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: Jiri Slaby <jirislaby@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Ted Ts'o <tytso@mit.edu>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Mon, 2011-05-16 at 16:10 -0700, John Stultz wrote:
> On Mon, 2011-05-16 at 23:54 +0200, Jiri Slaby wrote:
> > > In my attempt to clean up unprotected comm access, I've noticed
> > > most comm access is done for printk output. To simplify correct
> > > locking in these cases, I've introduced a new %ptc format,
> > > which will print the corresponding task's comm.
> > > Example use:
> > > printk("%ptc: unaligned epc - sending SIGBUS.\n", current);
> > > diff --git a/lib/vsprintf.c b/lib/vsprintf.c
[]
> > > +static noinline_for_stack
> > Actually, why noinline? Did your previous version have there some
> > TASK_COMM_LEN buffer or anything on stack which is not there anymore?
> No, I was just following how almost all of the pointer() called
> functions were declared.
> But with two pointers and a long, I add more then ip6_string() has on
> the stack, which uses the same notation.
> But I can drop that bit if there's really no need for it.

vsprintf can be recursive, I think you should keep it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
