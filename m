Message-ID: <397337EF.58667DD@colorfullife.com>
Date: Mon, 17 Jul 2000 18:44:31 +0200
From: Manfred Spraul <manfred@colorfullife.com>
MIME-Version: 1.0
Subject: Re: [PATCH] 2.2.17pre7 VM enhancement Re: I/O performance on
References: <Pine.LNX.4.21.0007171149440.30603-100000@duckman.distro.conectiva>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> 
> 
> Actually, FreeBSD has a special case in the page fault code
> for sequential accesses and I believe we must have that too.
> 

Where is that code? I found a sysctl parameter vm_pageout_algorithm_lru,
but nothing else.

> Both LRU and LFU break down on linear accesses to an array
> that doesn't fit in memory. In that case you really want
> MRU replacement, with some simple code that "detects the
> window size" you need to keep in memory. This seems to be
> the only way to get any speedup on such programs when you
> increase memory size to something which is still smaller
> than the total program size.
> 

Do you have an idea how to detect that situation?

--
	Manfred
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
