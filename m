Date: Sun, 21 Apr 2002 17:23:54 -0700
From: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Reply-To: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Subject: Re: Why *not* rmap, anyway?
Message-ID: <3051330941.1019409833@[10.10.2.3]>
In-Reply-To: <3CC33CDF.7F48A5B3@earthlink.net>
References: <3CC33CDF.7F48A5B3@earthlink.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Joseph A Knapka <jknapka@earthlink.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> I was just reading Bill's reply regaring rmap, and it
> seems to me that rmap is the most obvious and clean
> way to handle unmapping pages. So now I wonder why
> it wasn't done that way from the beginning?

Because it costs something to maintain the reverse map.
If the cost exceeds the benefit, it's not worth it. That's
why a bunch of us are working on bringing the cost down.
At the moment the cost is especially high on larger machines,
but we're getting there ... quickly ;-)

Martin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
