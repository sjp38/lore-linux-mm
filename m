Date: Tue, 10 Apr 2001 19:24:12 -0400 (EDT)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: Ideas for adding physically contiguous memory support to mmap()??
In-Reply-To: <C78C149684DAD311B757009027AA5CDC094DA2A8@xboi02.boi.hp.com>
Message-ID: <Pine.LNX.3.96.1010410191553.22333A-100000@kanga.kvack.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "LUTZ,TODD (HP-Boise,ex1)" <tlutz@hp.com>
Cc: "'linux-mm@kvack.org'" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 10 Apr 2001, LUTZ,TODD (HP-Boise,ex1) wrote:

> I would like to be able to extend mmap() (in 2.4.2) to support returning
> physically contiguous memory as shared memory.

> Here are some requirements:

> 1. Able to specify any size that is a multiple of PAGE_SIZE (not just powers
> of 2).

First off: why do you need this functionality?  It does not sound like it
provides any significant benefits over the current system once you take
into consideration the effects it will have on memory fragmentation.
Devices that require large chunks of memory are rare and specialised:
reasonable hardware provides support for scatter gather lists (they aren't
difficult to implement in hardware).

		-ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
