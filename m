Subject: Re: shm_alloc and friends
Date: Thu, 25 May 2000 15:59:44 +0100 (BST)
In-Reply-To: <200005251436.PAA02081@raistlin.arm.linux.org.uk> from "Russell King" at May 25, 2000 03:36:16 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <E12uz6w-0007xj-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Russell King <rmk@arm.linux.org.uk>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, riel@nl.linux.org, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > > Problems:
> > >  - memsetting the vmalloced area to initialise the pte's.
> > >    (Note: pte_clear can't be used, because that is expected to be used
> > 
> > Sorry that breaks S/390. You cannot use memset here.
> 
> Suggestions on a fix for that?

Use pte_clear. That is the only valid way to do it. Im not sure I follow why
you cant use pte_clear in this case


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
