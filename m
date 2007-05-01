Message-ID: <463696A9.8020909@redhat.com>
Date: Mon, 30 Apr 2007 21:23:53 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: MADV_FREE functionality
References: <20070430162007.ad46e153.akpm@linux-foundation.org>	<46368FAA.3080104@redhat.com> <20070430181839.c548c4da.akpm@linux-foundation.org>
In-Reply-To: <20070430181839.c548c4da.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk-manpages@gmx.net>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:

>> If you need any additional information, please let me know.
> 
> The patch doesn't update the various comments in madvise.c at all, which is
> a surprise.  Could you please check that they are all accurate and complete?

I'll take a look.

> Also, where did we end up with the Solaris compatibility?
> 
> The patch I have at present retains MADV_FREE=0x05 for sparc and sparc64
> which should be good.
> 
> Did we decide that the Solaris and Linux implementations of MADV_FREE are
> compatible?

Yes, the Linux, Solaris and FreeBSD implementations of MADV_FREE
appear to have equivalent semantics.

> What about the Solaris and Linux MADV_DONTNEED implementations?

This was never, and is still not, the same.  Linux will throw
away the data in anonymous pages while POSIX says we should
simply move the data to swap.  I assume Solaris and FreeBSD
will move the data to swap instead of throwing it away.

For file backed pages I suspect they all behave the same.

This is the reason that inside glibc, POSIX_MADV_DONTNEED is
a noop.

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
