Date: Tue, 3 Aug 1999 13:04:24 +0200
From: Andi Kleen <ak@muc.de>
Subject: Re: getrusage
Message-ID: <19990803130424.A2776@fred.muc.de>
References: <199908022159.RAA03948@grappelli.torrent.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <199908022159.RAA03948@grappelli.torrent.com>; from dca@torrent.com on Mon, Aug 02, 1999 at 11:59:18PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: dca@torrent.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 02, 1999 at 11:59:18PM +0200, dca@torrent.com wrote:
> The implementation of getrusage(2) appears incomplete in the stock
> 2.2.10 kernel; it's missing memory statistics e.g. the rss numbers.
> (It's also missing I/O statistics, but I assume you don't want to hear
> about them.)
> 
> Is this an old design decision, or simply an oversight?  If an
> oversight, I'd be happy to propose a patch for it.

How would you count e.g. shared mappings in a single RSS number  ? 

I think you need some more fine grained way to report memory use.


-Andi

-- 
This is like TV. I don't like TV.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
