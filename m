Received: from haymarket.ed.ac.uk (haymarket.ed.ac.uk [129.215.128.53])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA10273
	for <linux-mm@kvack.org>; Wed, 29 Jul 1998 11:55:13 -0400
Date: Wed, 29 Jul 1998 12:04:49 +0100
Message-Id: <199807291104.MAA01217@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: de-luxe zone allocator, design 2
In-Reply-To: <Pine.LNX.3.96.980728181426.6846B-100000@mirkwood.dummy.home>
References: <199807271112.MAA00732@dax.dcs.ed.ac.uk>
	<Pine.LNX.3.96.980728181426.6846B-100000@mirkwood.dummy.home>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, 28 Jul 1998 18:15:41 +0200 (CEST), Rik van Riel
<H.H.vanRiel@phys.uu.nl> said:

> On Mon, 27 Jul 1998, Stephen C. Tweedie wrote:
>> On Fri, 24 Jul 1998 23:03:18 +0200 (CEST), Rik van Riel
>> <H.H.vanRiel@phys.uu.nl> said:
>> 
>> > With the reports of Linux booting in 3 MB it's probably
>> > time for some low-mem adjustments, but in general this
>> > scheme should be somewhat better designed overall.
>> 
>> In 3MB, zoning in 128k chunks is crazy --- you want 8k chunks, max!

> Agreed, although 16k chunks would probably be better for
> 3 and 4 MB machines (allows DMA and network buffers).

In 2.1.112 we've now chopped down the default slab size for large
objects from 16k to 8k, so 8k should be OK.  (8k NFS still needs 16k
chunks, but you really want to be using 4k or smaller blocks on such
low memory machines anyway, for precisely this reason.)

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
