Date: Thu, 21 Oct 1999 15:40:15 -0400 (EDT)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: page faults
In-Reply-To: <Pine.LNX.4.10.9910211229110.32615-100000@imperial.edgeglobal.com>
Message-ID: <Pine.LNX.3.96.991021153709.3464D-100000@kanga.kvack.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: James Simmons <jsimmons@edgeglobal.com>
Cc: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 21 Oct 1999, James Simmons wrote:

> Quick question. If two processes are sharing the same memory but no page
> fault has happened. THen process A causes a page fault. If process B tries
> to access the page that process A already page fault will process B cause
> another page fault. Or do page faults only happen once no matter how many
> process access it. 

Only the first time the page is accessed is there a fault to put the entry
into the page table, regardless of the processes sharing the page.  The
only time entries are removed from a process' page tables is on fork
(ie marking private pages read only so COW works), unmap or vmscan's page
reclaims.

		-ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
