Message-ID: <007501bfdad3$26288e90$0a1e18ac@local>
From: "Manfred Spraul" <manfred@colorfullife.com>
References: <87r99t8m2r.fsf@atlas.iskon.hr> <000d01bfda37$f34c3ee0$0a1e18ac@local> <dnaeggn4o0.fsf@magla.iskon.hr>
Subject: Re: shrink_mmap() change in ac-21
Date: Tue, 20 Jun 2000 18:14:33 +0200
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: "Zlatko Calusic" <zlatko@iskon.hr>
Return-Path: <owner-linux-mm@kvack.org>
To: zlatko@iskon.hr
Cc: alan@redhat.com, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

>
> Simple mathematics: On a 128MB machine, DMA zone is 16MB, thus NORMAL
> zone is 112MB. 112/16 = 7. So statistically, for every DMA page freed,
> we free another SEVEN! pages from the NORMAL zone. And we won't stop
> doing such a genocide until DMA zone recovers.
>
I'm also concerned about 1GB boxes:
the highmem zone only contains ~ 64 MB (or 128?), and so most allocations go
into a tiny zone and are then "downgraded" to GFP_NORMAL.

Perhaps we should switch to per-zone lru lists?

--
    Manfred

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
