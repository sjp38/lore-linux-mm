Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 88F006B004A
	for <linux-mm@kvack.org>; Thu, 25 Nov 2010 01:46:22 -0500 (EST)
Message-ID: <4CEE0639.3090402@cs.helsinki.fi>
Date: Thu, 25 Nov 2010 08:46:17 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 2/2] [PATCH 2/2] tracing/slub: Move kmalloc tracepoint
 out of inline code
References: <20101124212333.808256210@goodmis.org>	 <20101124212717.468748477@goodmis.org>  <4CEDB53E.5000203@cn.fujitsu.com> <1290647846.30543.707.camel@gandalf.stny.rr.com>
In-Reply-To: <1290647846.30543.707.camel@gandalf.stny.rr.com>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Li Zefan <lizf@cn.fujitsu.com>, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Frederic Weisbecker <fweisbec@gmail.com>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, Richard Kennedy <richard@rsk.demon.co.uk>
List-ID: <linux-mm.kvack.org>

On 11/25/10 3:17 AM, Steven Rostedt wrote:
>> But he only touched slub.
>
> Hehe, and I forgot about it ;-) I notice the large number of kmalloc
> tracepoints while analyzing the jump label code, and wanted to do
> something about it.
>
> I also see that Pekka replied saying that he applied it.
>
> Pekka, want to take my first patch?

Sure, I'll queue it up.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
