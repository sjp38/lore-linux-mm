Message-ID: <391129F8.366659D4@sgi.com>
Date: Thu, 04 May 2000 00:42:48 -0700
From: Rajagopal Ananthanarayanan <ananth@sgi.com>
MIME-Version: 1.0
Subject: Re: Oops in __free_pages_ok (pre7-1) (Long) (backtrace)
References: <Pine.LNX.4.10.10005031828520.950-100000@penguin.transmeta.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Kanoj Sarcar <kanoj@google.engr.sgi.com>, linux-mm@kvack.org, "David S. Miller" <davem@redhat.com>
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:
> 
> Ok,
>  there's a pre7-4 out there that does the swapout with the page locked.

I did some testing of this patch with dbench.
The kernel starts shooting processes down pretty quickly
("VM: killing process XXX") on a 2 CPU 64MB system,
with nothing but dbench (8 clients). A concurrently
running vmstat shows very low free memory with some swapping,
and the buffer space remaining around 50MB.

I had applied the 7-4 patch on top of pre6.
When the patch was reversed (leaving just pre6),
the resulting kernel did not have any problems
running dbench in several tries.

Will try some more tomorrow after hearing others experience.

ananth.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
