Received: from [10.10.13.3]([10.10.13.3]) (1478 bytes) by megami.veritas.com
	via sendmail with P:esmtp/R:smart_host/T:smtp
	(sender: <hugh@veritas.com>)
	id <m179Plf-0006dZC@megami.veritas.com>
	for <linux-mm@kvack.org>; Sun, 19 May 2002 05:26:31 -0700 (PDT)
	(Smail-3.2.0.101 1997-Dec-17 #15 built 2001-Aug-30)
Date: Sun, 19 May 2002 13:29:28 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: working of balance_classzone()
In-Reply-To: <20020519085840.GA3660@SandStorm.net>
Message-ID: <Pine.LNX.4.21.0205191314520.9780-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Abhishek Nayani <abhi@kernelnewbies.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 19 May 2002, Abhishek Nayani wrote:
> 
> 	So the code in balance_classzone() looks very suspicious as it
> is acting as if there were many blocks of free pages of different orders
> on the list and we are trying to get the block of the correct order and
> then freeing the rest in reverse order.... 
> 
> 	Since there is only one block, we can cut the code to just check
> the order of that block, if its greater than our requirement, call
> rmqueue() else return NULL. 

The code hereabouts has been marooned for many releases, somewhere
in between what Andrea intended and what Linus wanted.  You're right
that there's a (harmless) mismatch between what __free_pages_ok is
actually doing, and what balance_classzone is expecting it to do.
But that should get sorted out when Andrea's further VM patches are
merged into 2.4.20... (always seems to be around the next corner).

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
