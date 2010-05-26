Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 67AEB6B01CD
	for <linux-mm@kvack.org>; Wed, 26 May 2010 07:10:21 -0400 (EDT)
Received: by fxm11 with SMTP id 11so3879430fxm.14
        for <linux-mm@kvack.org>; Wed, 26 May 2010 04:10:19 -0700 (PDT)
Date: Wed, 26 May 2010 13:10:18 +0200
From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: [PATCH] tracing: Remove kmemtrace ftrace plugin
Message-ID: <20100526111017.GG5311@nowhere>
References: <4BFCE849.7090804@cn.fujitsu.com> <20100526101617.GA14286@infradead.org> <20100526101837.GC5311@nowhere> <20100526102446.GA757@infradead.org> <20100526103222.GD5311@nowhere> <20100526110320.GA27011@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100526110320.GA27011@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Li Zefan <lizf@cn.fujitsu.com>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 26, 2010 at 07:03:20AM -0400, Christoph Hellwig wrote:
> On Wed, May 26, 2010 at 12:32:23PM +0200, Frederic Weisbecker wrote:
> > But which debugfs code? Nothing related to $(DEBUGFS)/tracing right?
> 
> Exactly.  Blktrace creates it's own files under $(DEBUGFS)/block when
> enabled through the old ioctls.


I see. So it has never been updated to support the ftrace plugin.
Fine then, lets remove it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
