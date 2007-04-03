Date: Tue, 3 Apr 2007 22:09:36 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: missing madvise functionality
Message-ID: <20070403200936.GA25541@one.firstfloor.org>
References: <46128051.9000609@redhat.com> <p73648dz5oa.fsf@bingen.suse.de> <46128CC2.9090809@redhat.com> <20070403172841.GB23689@one.firstfloor.org> <20070403125903.3e8577f4.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070403125903.3e8577f4.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Ulrich Drepper <drepper@redhat.com>, Rik van Riel <riel@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Jakub Jelinek <jakub@redhat.com>, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

> It might, a bit.  Both mmap() and mprotect() currently take mmap_sem() for
> writing.  If we're careful, we could probably arrange for MADV_ULRICH to
> take it for reading, which will help a little bit, hopefully.

The cache line bounces would be still there. Not sure that would help MySQL
all that much. 

Besides if the down_write is the real problem one could convert 
the code for all cases over to optimistic locking assuming most calls 
don't merge.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
