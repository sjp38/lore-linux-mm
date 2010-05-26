Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 67FBD6B01C1
	for <linux-mm@kvack.org>; Wed, 26 May 2010 06:18:40 -0400 (EDT)
Received: by fxm11 with SMTP id 11so3825649fxm.14
        for <linux-mm@kvack.org>; Wed, 26 May 2010 03:18:39 -0700 (PDT)
Date: Wed, 26 May 2010 12:18:38 +0200
From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: [PATCH] tracing: Remove kmemtrace ftrace plugin
Message-ID: <20100526101837.GC5311@nowhere>
References: <4BFCE849.7090804@cn.fujitsu.com> <20100526101617.GA14286@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100526101617.GA14286@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Li Zefan <lizf@cn.fujitsu.com>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 26, 2010 at 06:16:17AM -0400, Christoph Hellwig wrote:
> On Wed, May 26, 2010 at 05:22:17PM +0800, Li Zefan wrote:
> > We have been resisting new ftrace plugins and removing existing
> > ones, and kmemtrace has been superseded by kmem trace events
> > and perf-kmem, so we remove it.
> 
> While you're at it also care to remove the blk ftrace plugin?  We have
> the old blktrace ioctl interface and the trace events as better
> alternatives.


But does the userspace tool support them?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
