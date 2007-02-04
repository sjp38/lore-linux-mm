Date: Sun, 4 Feb 2007 10:26:29 +0000
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [patch 9/9] mm: fix pagecache write deadlocks
Message-ID: <20070204102629.GA8785@infradead.org>
References: <20070204063707.23659.20741.sendpatchset@linux.site> <20070204063833.23659.55105.sendpatchset@linux.site> <20070204014445.88e6c8c7.akpm@linux-foundation.org> <20070204101529.GA22004@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070204101529.GA22004@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Filesystems <linux-fsdevel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, Feb 04, 2007 at 11:15:29AM +0100, Nick Piggin wrote:
> Cool, a kernel thread is calling sys_write. Fun.

There are tons of places where we possible call into ->write from
either kernel threads or at least with a kernel pointer  and set_fs/set_ds
magic.  Anything in the buffer write path that tries to touch page tables
can't work.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
