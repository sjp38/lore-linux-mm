Message-ID: <3966087C.D4D9E74E@colorfullife.com>
Date: Fri, 07 Jul 2000 18:42:36 +0200
From: Manfred Spraul <manfred@colorfullife.com>
MIME-Version: 1.0
Subject: Re: sys_exit() and zap_page_range()
References: <3965EC8E.5950B758@uow.edu.au>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <andrewm@uow.edu.au>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> 
> Can anyone suggest a simple, clean way of decreasing zap_page_range's
> scheduling latency, in a way which you're prepared to support?
> 
Btw, zap_page_range() contains a huge TLB flush race: the freed pages
become available immediately to other processes, but stale tlb entries
are only flushed when zap_page_range() returns [check madvise_dontneed,
and several other functions]

A proper fix would be a major change, probably along Kanoj's proposal
(pte_freeze_range).

--
	Manfred
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
