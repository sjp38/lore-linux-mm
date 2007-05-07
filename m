Message-ID: <463EB169.8030701@redhat.com>
Date: Mon, 07 May 2007 00:56:09 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] MM: implement MADV_FREE lazy freeing of anonymous memory
References: <4632D0EF.9050701@redhat.com> <463B108C.10602@yahoo.com.au> <463B598B.80200@redhat.com> <463BC62C.3060605@yahoo.com.au> <463E5A00.6070708@redhat.com> <463E921D.3070407@redhat.com>
In-Reply-To: <463E921D.3070407@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ulrich Drepper <drepper@redhat.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Jakub Jelinek <jakub@redhat.com>
List-ID: <linux-mm.kvack.org>

Ulrich Drepper wrote:
> Rik van Riel wrote:
>> I think that maybe for 2.6.22 we should just alias MADV_FREE
>> to run with the MADV_DONTNEED functionality, so that the glibc
>> people can make the change on their side while we figure out
>> what will be the best thing to do on the kernel side.
> 
> No need for that.  We can later extend glibc to use MADV_FREE and fall 
> back on MADV_DONTNEED.

It's trivial to merge the MADV_FREE #defines into the kernel
though, and aliasing MADV_FREE to MADV_DONTNEED for the time
being is a one-liner - just an extra constant into the big
switch statement in sys_madvise().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
