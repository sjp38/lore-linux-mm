Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 9CA6E6B01BE
	for <linux-mm@kvack.org>; Wed, 26 May 2010 06:16:56 -0400 (EDT)
Date: Wed, 26 May 2010 06:16:17 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] tracing: Remove kmemtrace ftrace plugin
Message-ID: <20100526101617.GA14286@infradead.org>
References: <4BFCE849.7090804@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4BFCE849.7090804@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, Frederic Weisbecker <fweisbec@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 26, 2010 at 05:22:17PM +0800, Li Zefan wrote:
> We have been resisting new ftrace plugins and removing existing
> ones, and kmemtrace has been superseded by kmem trace events
> and perf-kmem, so we remove it.

While you're at it also care to remove the blk ftrace plugin?  We have
the old blktrace ioctl interface and the trace events as better
alternatives.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
