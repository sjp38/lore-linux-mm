Date: Sat, 21 Apr 2007 08:37:03 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH] lazy freeing of memory through MADV_FREE 2/2
In-Reply-To: <a36005b50704201424q3c07d457m6b2c468ff8a826c7@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0704210830310.26485@blonde.wat.veritas.com>
References: <46247427.6000902@redhat.com> <4627DBF0.1080303@redhat.com>
 <20070420140316.e0155e7d.akpm@linux-foundation.org>
 <a36005b50704201424q3c07d457m6b2c468ff8a826c7@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ulrich Drepper <drepper@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Jakub Jelinek <jakub@redhat.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 20 Apr 2007, Ulrich Drepper wrote:
> 
> Just for reference: the MADV_CURRENT behavior is to throw away data in
> the range.

Not exactly.  The Linux MADV_DONTNEED never throws away data from a
PROT_WRITE,MAP_SHARED mapping (or shm) - it propagates the dirty bit,
the page will eventually get written out to file, and can be retrieved
later by subsequent access.  But the Linux MADV_DONTNEED does throw away
data from a PROT_WRITE,MAP_PRIVATE mapping (or brk or stack) - those
changes are discarded, and a subsequent access will revert to zeroes
or the underlying mapped file.  Been like that since before 2.4.0.

> The POSIX_MADV_DONTNEED behavior is to never lose data.
> I.e., file backed data is written back, anon data is at most swapped
> out.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
