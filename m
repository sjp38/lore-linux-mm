Subject: Re: shm_alloc and friends
Date: Thu, 25 May 2000 16:59:40 +0100 (BST)
In-Reply-To: <200005251520.QAA02278@raistlin.arm.linux.org.uk> from "Russell King" at May 25, 2000 04:20:10 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <E12v02v-00084O-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Russell King <rmk@arm.linux.org.uk>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, riel@nl.linux.org, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > Use pte_clear. That is the only valid way to do it. Im not sure I follow why
> > you cant use pte_clear in this case
> 
> pte_clear has other side effects on ARM, since we don't have enough bits in the
> page tables to store all the bits that Linux needs.  In fact, there are NO bits
> in the page table entries which are not CPU defined.

How about adding a seperate pte_init() then ?

> Therefore, really SHM's use of pte_clear is a hack in the extreme, breaking the
> architecture independence of the page table macros.

Agreed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
