Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id C51BA475B4
	for <linux-mm@kvack.org>; Fri,  6 Dec 2002 14:08:26 -0200 (BRST)
Date: Fri, 6 Dec 2002 14:08:17 -0200 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Question on pte bits
In-Reply-To: <3DF0BAD4.946B1845@scs.ch>
Message-ID: <Pine.LNX.4.50L.0212061407120.22252-100000@duckman.distro.conectiva>
References: <3DF0BAD4.946B1845@scs.ch>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Maletinsky <maletinsky@scs.ch>
Cc: linux-mm@kvack.org, kernelnewbies@nl.linux.org
List-ID: <linux-mm.kvack.org>

On Fri, 6 Dec 2002, Martin Maletinsky wrote:

> After getting the corresponding page table entry, the function makes a
> check, which I don't quite understand - if write access is requested to
> the page, it not only checks the write permission in the page table
> entry (with pte_write()), but also the dirty bit (with pte_dirty()). Why
> does a page need to be dirty in the case write == 1 (see line 444 in the
> code excerpt below?

If write == 1, then somebody wants to write to the page NOW.
In that case it's more efficient to just set the dirty bit
than to take a trap later on; remember that many CPUs can't
keep track of the dirty bit in hardware but trap to the OS.

Rik
-- 
A: No.
Q: Should I include quotations after my reply?
http://www.surriel.com/		http://guru.conectiva.com/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
