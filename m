Received: from haymarket.ed.ac.uk (haymarket.ed.ac.uk [129.215.128.53])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA31185
	for <linux-mm@kvack.org>; Mon, 27 Jul 1998 15:44:44 -0400
Date: Mon, 27 Jul 1998 12:12:23 +0100
Message-Id: <199807271112.MAA00732@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: de-luxe zone allocator, design 2
In-Reply-To: <Pine.LNX.3.96.980724225908.30437A-200000@mirkwood.dummy.home>
References: <Pine.LNX.3.96.980724225908.30437A-200000@mirkwood.dummy.home>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Fri, 24 Jul 1998 23:03:18 +0200 (CEST), Rik van Riel
<H.H.vanRiel@phys.uu.nl> said:

> With the reports of Linux booting in 3 MB it's probably
> time for some low-mem adjustments, but in general this
> scheme should be somewhat better designed overall.

In 3MB, zoning in 128k chunks is crazy --- you want 8k chunks, max!
The extra cost incurred by less efficient packing will also cripple
you on 3MB with zones.  The problem definition is different on such
small machines.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
