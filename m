Received: from haymarket.ed.ac.uk (haymarket.ed.ac.uk [129.215.128.53])
	by kvack.org (8.8.7/8.8.7) with ESMTP id FAA21624
	for <linux-mm@kvack.org>; Fri, 31 Jul 1998 05:48:32 -0400
Date: Fri, 31 Jul 1998 00:35:16 +0100
Message-Id: <199807302335.AAA07710@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: de-luxe zone allocator, design 2
In-Reply-To: <Pine.LNX.3.96.980729195814.12136G-100000@mirkwood.dummy.home>
References: <199807291104.MAA01217@dax.dcs.ed.ac.uk>
	<Pine.LNX.3.96.980729195814.12136G-100000@mirkwood.dummy.home>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, 29 Jul 1998 20:00:14 +0200 (CEST), Rik van Riel
<H.H.vanRiel@phys.uu.nl> said:

> Isn't packing locality _very_ important on machines where you
> have no memory to spare? In that case 16k would probably be
> better; PLUS 16k will allow for real DMA buffers and stuff.

Not for short-lived packets, where you don't want to reserve a whole 16k
or more just for a single instance of an NFS packet.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
