Date: Wed, 22 Mar 2000 22:44:08 +0000
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: madvise (MADV_FREE)
Message-ID: <20000322224408.I2850@redhat.com>
References: <20000322190532.A7212@pcep-jamie.cern.ch> <Pine.BSO.4.10.10003221554170.17378-100000@funky.monkey.org> <20000322233147.A31795@pcep-jamie.cern.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20000322233147.A31795@pcep-jamie.cern.ch>; from jamie.lokier@cern.ch on Wed, Mar 22, 2000 at 11:31:47PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jamie Lokier <jamie.lokier@cern.ch>
Cc: Chuck Lever <cel@monkey.org>, linux-mm@kvack.org, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Mar 22, 2000 at 11:31:47PM +0100, Jamie Lokier wrote:
> 
> No they don't.  MADV_DONTNEED always discards private modifications.
> (BTW I think it should be flushing the swap cache while it's at it).

If it is the last user of the page --- ie. if PG_SwapCache is set and
the refcount of the page is one --- then it will do so anyway, because
when I added that swap cache code I made sure that zap_page_range()
does a free_page_and_swap_cache() when freeing pages.

--Stephen

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
