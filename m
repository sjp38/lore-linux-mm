Date: Sat, 17 Jun 2000 16:43:18 -0300
Subject: Re: kswapd eating too much CPU on ac16/ac18
Message-ID: <20000617164317.A9421@cesarb.personal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
From: Cesar Eduardo Barros <cesarb@nitnet.com.br>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roger Larsson <roger.larsson@optronic.se>
Cc: "'linux-mm@kvack.org'" <linux-mm@kvack.org>, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

> Please try to remove only this test to get a comparable result.

I nuked the whole block:

                /*
                 * Page is from a zone we don't care about.
                 * Don't drop page cache entries in vain.
                 */
                if (page->zone->free_pages > page->zone->pages_high) {
                        /* the page from the wrong zone doesn't count */
                        count++;
                        goto unlock_continue;
                }

Commenting it out made ac19 perform almost as good as ac4 (it looked a bit
faster).

I don't know how it would affect boxes with more than one zone, but my gut
feeling is that it won't hurt and might make them even a bit faster.

-- 
Cesar Eduardo Barros
cesarb@nitnet.com.br
cesarb@dcc.ufrj.br
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
