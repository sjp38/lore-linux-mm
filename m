Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id D79896B0029
	for <linux-mm@kvack.org>; Wed, 18 May 2011 03:05:24 -0400 (EDT)
Date: Wed, 18 May 2011 00:05:27 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/4] v6 Improve task->comm locking situation
Message-Id: <20110518000527.bcced636.akpm@linux-foundation.org>
In-Reply-To: <20110518062554.GB2945@elte.hu>
References: <1305682865-27111-1-git-send-email-john.stultz@linaro.org>
	<20110518062554.GB2945@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: John Stultz <john.stultz@linaro.org>, LKML <linux-kernel@vger.kernel.org>, Joe Perches <joe@perches.com>, Michal Nazarewicz <mina86@mina86.com>, Andy Whitcroft <apw@canonical.com>, Jiri Slaby <jirislaby@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>

On Wed, 18 May 2011 08:25:54 +0200 Ingo Molnar <mingo@elte.hu> wrote:

>   " Hey, this looks a bit racy and 'top' very rarely, on rare workloads that 
>     play with ->comm[], might display a weird reading task name for a second, 
>     amongst the many other temporarily nonsensical statistical things it 
>     already prints every now and then. "

Well we should at least make sure that `top' won't run off the end of
comm[] and go oops.  I think that's guaranteed by the fact(s) that
init_tasks's comm[15] is zero and is always copied-by-value across
fork and can never be overwritten in any task_struct.

But I didn't check that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
