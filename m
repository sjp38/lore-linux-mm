Subject: Re: shm_alloc and friends
References: <200005251436.PAA02081@raistlin.arm.linux.org.uk>
From: eric@biederman.org (Eric W. Biederman)
Date: 26 May 2000 09:07:37 -0500
In-Reply-To: Russell King's message of "Thu, 25 May 2000 15:36:16 +0100 (BST)"
Message-ID: <m1ya4xl80m.fsf@frodo.biederman.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Russell King <rmk@arm.linux.org.uk> writes:

> Alan Cox writes:
> > > Problems:
> > >  - memsetting the vmalloced area to initialise the pte's.
> > >    (Note: pte_clear can't be used, because that is expected to be used
> > 
> > Sorry that breaks S/390. You cannot use memset here.
> 
> Suggestions on a fix for that?

Purge pte_t from the code.  Just use swp_entry_t.
The page cache has all of the necessary mechanisms for testing
to see if a page is present or not already.

That should make memset safe as well...

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
