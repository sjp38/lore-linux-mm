Received: (from john@localhost)
	by boreas.southchinaseas (8.9.3/8.9.3) id XAA07235
	for <linux-mm@kvack.org>; Sun, 11 Jun 2000 23:16:53 +0100
Subject: Re: VM callbacks and VM design
References: <yttem69ccax.fsf@serpe.mitica> <20000607180737.A5943@acs.ucalgary.ca>
From: "John Fremlin" <vii@penguinpowered.com>
Date: 11 Jun 2000 23:16:52 +0100
In-Reply-To: Neil Schemenauer's message of "Wed, 7 Jun 2000 18:07:37 -0600"
Message-ID: <m2snuj278r.fsf@boreas.southchinaseas>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Neil Schemenauer <nascheme@enme.ucalgary.ca> writes:

[...]

> In order to decide which pages are good candidates for freeing
> the temporal locality heuristic should be used (ie. pages needed

Why?

> recently will also be needed in the near future).  Note that this
> is different that "most often used".  I think Rik's latest aging
> patch is slightly wrong in this regard.

If you're greping through a large file you don't want to swap out your
processes.

Also, you might like to look at the ideas behind generational garbage
collection; i.e. most objects are used briefly then forgotten about
forever, but those which are still being used after a while will
probably keep on being used.

[...]

-- 

	http://altern.org/vii
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
