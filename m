Subject: Re: shrink_mmap() change in ac-21
References: <Pine.LNX.4.21.0006201258190.12944-100000@duckman.distro.conectiva>
From: "Juan J. Quintela" <quintela@fi.udc.es>
In-Reply-To: Rik van Riel's message of "Tue, 20 Jun 2000 13:18:38 -0300 (BRST)"
Date: 20 Jun 2000 18:53:00 +0200
Message-ID: <yttpupcmh03.fsf@serpe.mitica>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Andrea Arcangeli <andrea@suse.de>, Jamie Lokier <lk@tantalophile.demon.co.uk>, Zlatko Calusic <zlatko@iskon.hr>, alan@redhat.com, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

>>>>> "rik" == Rik van Riel <riel@conectiva.com.br> writes:

Hi

rik> Also, since kswapd stops when all zones have free_pages
rik> above pages_low and we'll free up to pages_high pages of
rik> one zone, it means that we'll:

rik> - allocate the next series of pages from that one zone
rik>   with tons of unused pages
rik> - wake up kswapd so we'll free the *next* unused pages
rik>   from that zone when we run out of the current batch
rik> - rinse and repeat

That is what my change to page_alloc does, it makes more probable to
get pages from zones that have more than page_high free pages.  That
means that it is less probable to get one zone with less than page_low
free pages and other with a lot of free pages.

Notice that this behaviour happens also in my box where there is no
ISA cards at all, and I have to wait for a page to become free in the
DMA zone.  Is there some way to need a DMA page in a machine without
any ISA card?  If not, it could be a good Idea to have only one zone
in machines that haven't ISA cards and have less than 1GB of RAM.

Later, Juan.

-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
