Message-ID: <380FB40C.16662EDA@263.net>
Date: Fri, 22 Oct 1999 08:47:08 +0800
From: Wang Yong <wung_y@263.net>
Reply-To: wung_y@263.net
MIME-Version: 1.0
Subject: Re: page faults
References: <Pine.LNX.3.96.991021153709.3464D-100000@kanga.kvack.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mail list linux-mm mail list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

the page fault is an interrupt and do_page_fault is the handler, so no other
page fault
will be received in do_page_fault. this is true for linux because it's not
preemptive.
if the page fault is caused by a write to a shared page, do_wp_page will be
called
to copy this page to a new page(copy on write).

"Benjamin C.R. LaHaise" wrote:

> On Thu, 21 Oct 1999, James Simmons wrote:
>
> > Quick question. If two processes are sharing the same memory but no page
> > fault has happened. THen process A causes a page fault. If process B tries
> > to access the page that process A already page fault will process B cause
> > another page fault. Or do page faults only happen once no matter how many
> > process access it.
>
> Only the first time the page is accessed is there a fault to put the entry
> into the page table, regardless of the processes sharing the page.  The
> only time entries are removed from a process' page tables is on fork
> (ie marking private pages read only so COW works), unmap or vmscan's page
> reclaims.
>
>                 -ben
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://humbolt.geo.uu.nl/Linux-MM/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
