Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 0F0A16B0087
	for <linux-mm@kvack.org>; Fri, 20 Nov 2009 03:20:24 -0500 (EST)
Message-ID: <4B065145.2000709@cs.helsinki.fi>
Date: Fri, 20 Nov 2009 10:20:21 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] tracing: Remove kmemtrace tracer
References: <4B064AF5.9060208@cn.fujitsu.com> <4B064B0B.30207@cn.fujitsu.com>
In-Reply-To: <4B064B0B.30207@cn.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Ingo Molnar <mingo@elte.hu>, Frederic Weisbecker <fweisbec@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <peterz@infradead.org>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Li Zefan kirjoitti:
> The kmem trace events can replace the functions of kmemtrace
> tracer.
> 
> And kmemtrace-user can be modified to use trace events.
> (But after cloning the git repo, I found it's still based on
> the original relay version..), not to mention now we have
> 'perf kmem' tool.
> 
> Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>

NAK for the time being. "perf kmem" output is not yet as good as that of 
kmemtrace-user.

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
