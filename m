Subject: Re: Documentation/vm/locking: why not hold two PT locks?
From: Robert Love <rml@ximian.com>
In-Reply-To: <87ekt5ckgu.fsf@cs.uga.edu>
References: <8765ehe0cu.fsf@uga.edu> <1076275778.5608.1.camel@localhost>
	 <87ekt5ckgu.fsf@cs.uga.edu>
Content-Type: text/plain
Message-Id: <1076278320.6015.1.camel@localhost>
Mime-Version: 1.0
Date: Sun, 08 Feb 2004 17:12:00 -0500
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed L Cashin <ecashin@uga.edu>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 2004-02-08 at 16:47 -0500, Ed L Cashin wrote:

> If that's all there is to it, then in my case, I have imposed a
> locking hierarchy on my own code, so that wouldn't happen in my code.
> I have a semaphore "S" outside of mmap_sem and page_table_lock.  Every
> call path that can get to my code takes S before getting the
> mmap_sem.  

Well, you don't follow a locking hierarchy either, you just have a
global synchronizer (your semaphore S).  Same effect, sure, you cannot
deadlock.

But anyone else who touches two or more PT's will deadlock.

> So it looks like my code is safe but not so efficient, since T2 has to
> sleep when it doesn't get the semaphore S.  Is there some other
> complication I'm missing?

It could be that _I_ am missing something, and there is another reason
why we don't grab more than one PT concurrently.  But the locking
hierarchy is still a concern.

	Robert Love


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
