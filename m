Message-ID: <001d01bfdadd$a41dfec0$0a1e18ac@local>
From: "Manfred Spraul" <manfred@colorfullife.com>
References: <Pine.LNX.4.21.0006201258190.12944-100000@duckman.distro.conectiva> <yttpupcmh03.fsf@serpe.mitica>
Subject: Re: shrink_mmap() change in ac-21
Date: Tue, 20 Jun 2000 19:30:26 +0200
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: "Juan J. Quintela" <quintela@fi.udc.es>
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>, "Juan J. Quintela" <quintela@fi.udc.es>
Cc: Andrea Arcangeli <andrea@suse.de>, Jamie Lokier <lk@tantalophile.demon.co.uk>, Zlatko Calusic <zlatko@iskon.hr>, alan@redhat.com, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

>
> Notice that this behaviour happens also in my box where there is no
> ISA cards at all, and I have to wait for a page to become free in the
> DMA zone.  Is there some way to need a DMA page in a machine without
> any ISA card?  If not, it could be a good Idea to have only one zone
> in machines that haven't ISA cards and have less than 1GB of RAM.
>
How do you want to find out that a box has no ISA card?
Additionally, the floppy disk needs GFP_DMA memory and IIRC some non-ISA
sound cards have < 32 (28?) address lines.

--
    Manfred



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
