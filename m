Received: from magicnet.magicnet.net (root@magicnet.magicnet.net [204.96.116.9])
	by kvack.org (8.8.7/8.8.7) with ESMTP id UAA21471
	for <linux-mm@kvack.org>; Fri, 19 Jun 1998 20:48:40 -0400
Message-Id: <3.0.5.32.19980619204827.00959970@magicnet.net>
Date: Fri, 19 Jun 1998 20:48:27 -0400
From: George Woltman <woltman@magicnet.net>
Subject: Re: update re: fork() failures [in 2.1.103]
In-Reply-To: <19980619161417.40049@adore.lightlink.com>
References: <Pine.LNX.3.96.980619185625.6318F-100000@mirkwood.dummy.home>
 <19980619110148.53909@adore.lightlink.com>
 <Pine.LNX.3.96.980619185625.6318F-100000@mirkwood.dummy.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
To: Paul Kimoto <kimoto@lightlink.com>, Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

At 04:14 PM 6/19/98 -0400, Paul Kimoto wrote:
>
>I *think* that it allocates a huge amount of memory,
>then uses only a small portion of it.

This is indeed the case.  I know it's a sloppy programming practice,
but it was the easiest way for me to interface with all my assembly
code that assumes the FFT data is at a fixed address.  Mprime actually
has 16MB of global variables.  Unless you are testing an exponent above
20,000,000 then you are only using a small fraction of the 16MB.

Best regards,
George
