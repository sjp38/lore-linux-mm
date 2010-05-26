Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 494AA6002CC
	for <linux-mm@kvack.org>; Wed, 26 May 2010 06:32:26 -0400 (EDT)
Received: by fxm11 with SMTP id 11so3839846fxm.14
        for <linux-mm@kvack.org>; Wed, 26 May 2010 03:32:24 -0700 (PDT)
Date: Wed, 26 May 2010 12:32:23 +0200
From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: [PATCH] tracing: Remove kmemtrace ftrace plugin
Message-ID: <20100526103222.GD5311@nowhere>
References: <4BFCE849.7090804@cn.fujitsu.com> <20100526101617.GA14286@infradead.org> <20100526101837.GC5311@nowhere> <20100526102446.GA757@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100526102446.GA757@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Li Zefan <lizf@cn.fujitsu.com>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 26, 2010 at 06:24:46AM -0400, Christoph Hellwig wrote:
> On Wed, May 26, 2010 at 12:18:38PM +0200, Frederic Weisbecker wrote:
> > But does the userspace tool support them?
> 
> The blktrace userspace tool only uses the ioctl/debugfs code.
> 


But which debugfs code? Nothing related to $(DEBUGFS)/tracing right?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
