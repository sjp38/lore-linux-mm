Message-ID: <463EB0C4.6060901@redhat.com>
Date: Sun, 06 May 2007 21:53:24 -0700
From: Ulrich Drepper <drepper@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] MM: implement MADV_FREE lazy freeing of anonymous memory
References: <4632D0EF.9050701@redhat.com> <463B108C.10602@yahoo.com.au> <463B598B.80200@redhat.com> <463BC62C.3060605@yahoo.com.au> <463E5A00.6070708@redhat.com> <463E921D.3070407@redhat.com> <463EB169.8030701@redhat.com>
In-Reply-To: <463EB169.8030701@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Jakub Jelinek <jakub@redhat.com>
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> It's trivial to merge the MADV_FREE #defines into the kernel
> though, and aliasing MADV_FREE to MADV_DONTNEED for the time
> being is a one-liner - just an extra constant into the big
> switch statement in sys_madvise().

Until the semantics of the implementation is cut into stone by having it 
in the kernel I'll not start using it.

-- 
a?? Ulrich Drepper a?? Red Hat, Inc. a?? 444 Castro St a?? Mountain View, CA a??

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
