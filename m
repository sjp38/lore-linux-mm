Subject: Re: shrink_mmap() change in ac-21
References: <Pine.LNX.4.21.0006201258190.12944-100000@duckman.distro.conectiva>
	<yttpupcmh03.fsf@serpe.mitica> <001d01bfdadd$a41dfec0$0a1e18ac@local>
From: "Juan J. Quintela" <quintela@fi.udc.es>
In-Reply-To: "Manfred Spraul"'s message of "Tue, 20 Jun 2000 19:30:26 +0200"
Date: 20 Jun 2000 19:41:23 +0200
Message-ID: <yttbt0wmerg.fsf@serpe.mitica>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Manfred Spraul <manfred@colorfullife.com>
Cc: Rik van Riel <riel@conectiva.com.br>, Andrea Arcangeli <andrea@suse.de>, Jamie Lokier <lk@tantalophile.demon.co.uk>, Zlatko Calusic <zlatko@iskon.hr>, alan@redhat.com, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

>>>>> "manfred" == Manfred Spraul <manfred@colorfullife.com> writes:

manfred> From: "Juan J. Quintela" <quintela@fi.udc.es>
>> 
>> Notice that this behaviour happens also in my box where there is no
>> ISA cards at all, and I have to wait for a page to become free in the
>> DMA zone.  Is there some way to need a DMA page in a machine without
>> any ISA card?  If not, it could be a good Idea to have only one zone
>> in machines that haven't ISA cards and have less than 1GB of RAM.
>> 
manfred> How do you want to find out that a box has no ISA card?
manfred> Additionally, the floppy disk needs GFP_DMA memory and IIRC some non-ISA
manfred> sound cards have < 32 (28?) address lines.

I have no idea how to find out that a BOX have no ISA cards.  That was
only a suggestion.  Perhaps asking if you want ISA zone during
configuration??  I have no idea about floppy and some non ISA cards,
they are a problem.  But the point here is that I am not using floppy
on that machine, no Sound Card on that machine, and I have to wait for
a DMA page to become free (when nobody is asking, will ask for DMA
memory...)  Perhaps it is too late to solve that problem for 2.4, but
it appears that somebody needs to think a bit about the problem.

Later, Juan.

-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
