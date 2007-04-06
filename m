Message-ID: <4615B043.8060001@yahoo.com.au>
Date: Fri, 06 Apr 2007 12:28:19 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: missing madvise functionality
References: <46128051.9000609@redhat.com> <p73648dz5oa.fsf@bingen.suse.de> <46128CC2.9090809@redhat.com> <20070403172841.GB23689@one.firstfloor.org> <20070403125903.3e8577f4.akpm@linux-foundation.org> <4612B645.7030902@redhat.com> <20070403202937.GE355@devserv.devel.redhat.com> <4614A5CC.5080508@redhat.com> <46151F73.50602@redhat.com>
In-Reply-To: <46151F73.50602@redhat.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ulrich Drepper <drepper@redhat.com>
Cc: Rik van Riel <riel@redhat.com>, Jakub Jelinek <jakub@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Ulrich Drepper wrote:
> In case somebody wants to play around with Rik patch or another
> madvise-based patch, I have x86-64 glibc binaries which can use it:
> 
>   http://people.redhat.com/drepper/rpms
> 
> These are based on the latest Fedora rawhide version.  They should work
> on older systems, too, but you screw up your updates.  Use them only if
> you know what you do.
> 
> By default madvise(MADV_DONTNEED) is used.  With the environment variable

Cool. According to my thinking, madvise(MADV_DONTNEED) even in today's
kernels using down_write(mmap_sem) for MADV_DONTNEED is better than
mmap/mprotect, which have more fundamental locking requirements, more
overhead and no benefits (except debugging, I suppose).

MADV_DONTNEED is twice as fast in single threaded performance, and an
order of magnitude faster for multiple threads, when MADV_DONTNEED only
takes mmap_sem for read.

Do you plan to include this change in general glibc releases? Maybe it
will make google malloc obsolete? ;) (I don't suppose you'd be able to
get any tests done, Andrew?)

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
