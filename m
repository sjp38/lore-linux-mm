Message-ID: <44C86FB9.6090709@redhat.com>
Date: Thu, 27 Jul 2006 03:48:09 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: use-once cleanup
References: <1153168829.31891.89.camel@lappy>
In-Reply-To: <1153168829.31891.89.camel@lappy>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm <linux-mm@kvack.org>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Nick Piggin <piggin@cyberone.com.au>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Peter Zijlstra wrote:
> Hi,
> 
> This is yet another implementation of the PG_useonce cleanup spoken of
> during the VM summit.

After getting bitten by rsync yet again, I guess it's time to insist
that this patch gets merged...

Andrew, could you merge this?  Pretty please? ;)

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
