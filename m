Date: Sun, 16 Dec 2001 16:09:55 +0100
From: Christoph Hellwig <hch@caldera.de>
Subject: Re: Thread specific data
Message-ID: <20011216160955.A21103@caldera.de>
References: <20011216125219.1450.qmail@web12004.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20011216125219.1450.qmail@web12004.mail.yahoo.com>; from anumulavenkat@yahoo.com on Sun, Dec 16, 2001 at 04:52:19AM -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Anumula Venkat <anumulavenkat@yahoo.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Dec 16, 2001 at 04:52:19AM -0800, Anumula Venkat wrote:
> Hello Friends,
> 
>     Can somebody help in knowing how to access thread
> data structures on kernel side.i.e accessing thread
> specific data in stack segment.

The Linux kernel has a unified process/thread concept so there isn't
really a 'thread data structure' in the kernel.  See linux/sched.h
for details.

For userspace stack this is handle by glibc/linuxthreads.  On i686
it uses sys_modify_ldt to get per-thread segments, not sure how it
is handled on older CPUs / other architectures.

	Christoph

-- 
Of course it doesn't work. We've performed a software upgrade.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
