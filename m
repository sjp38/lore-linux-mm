Date: Fri, 23 Jun 2000 18:56:44 +0100
From: Stephen Tweedie <sct@redhat.com>
Subject: Re: [RFC] RSS guarantees and limits
Message-ID: <20000623185644.C10285@redhat.com>
References: <85256907.004D1292.00@D51MTA03.pok.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <85256907.004D1292.00@D51MTA03.pok.ibm.com>; from frankeh@us.ibm.com on Fri, Jun 23, 2000 at 10:01:14AM -0400
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: frankeh@us.ibm.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Fri, Jun 23, 2000 at 10:01:14AM -0400, frankeh@us.ibm.com wrote:
> How is shared memory accounted for?

Shared memory has nothing to do with RSSes --- the RSS is strictly 
a per-process concept.  If a process exhausts its RSS, then pages are
removed from that process's working set, but these pages are not
immediately evicted from physical memory.  If the page is faulted back
in before being finally evicted from memory, ten there is no disk IO
involved. 

The advantage of the RSS limit here is that the pages which are
evicted from working set but not from memory are MUCH easier for the
VM to evict later if we run out of physical free pages.  If we are
under memory pressure, then the RSS limit causes us to prefer to page
out the pages of processes who are above their RSS limit.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
