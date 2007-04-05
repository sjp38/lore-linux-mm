Date: Thu, 5 Apr 2007 01:32:25 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: missing madvise functionality
Message-Id: <20070405013225.4135b76d.akpm@linux-foundation.org>
In-Reply-To: <4614A7B1.60808@redhat.com>
References: <46128051.9000609@redhat.com>
	<p73648dz5oa.fsf@bingen.suse.de>
	<46128CC2.9090809@redhat.com>
	<20070403172841.GB23689@one.firstfloor.org>
	<20070403125903.3e8577f4.akpm@linux-foundation.org>
	<4612B645.7030902@redhat.com>
	<20070403202937.GE355@devserv.devel.redhat.com>
	<4614A5CC.5080508@redhat.com>
	<4614A7B1.60808@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Jakub Jelinek <jakub@redhat.com>, Ulrich Drepper <drepper@redhat.com>, Andi Kleen <andi@firstfloor.org>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Thu, 05 Apr 2007 03:39:29 -0400 Rik van Riel <riel@redhat.com> wrote:

> Rik van Riel wrote:
> 
> > MADV_DONTNEED, unpatched, 1000 loops
> > 
> > real    0m13.672s
> > user    0m1.217s
> > sys     0m45.712s
> > 
> > 
> > MADV_DONTNEED, with patch, 1000 loops
> > 
> > real    0m4.169s
> > user    0m2.033s
> > sys     0m3.224s
> 
> I just noticed something fun with these numbers.
> 
> Without the patch, the system (a quad core CPU) is 10% idle.
> 
> With the patch, it is 66% idle - presumably I need Nick's
> mmap_sem patch.
> 
> However, despite being 66% idle, the test still runs over
> 3 times as fast!

Please quote the context switch rate when testing this stuff (I use vmstat 1).
I've seen it vary by a factor of 10,000 depending upon what's happening.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
