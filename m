Date: Mon, 7 May 2001 00:07:49 +0200 (CEST)
From: BERECZ Szabolcs <szabi@inf.elte.hu>
Subject: Re: page_launder() bug
In-Reply-To: <l03130303b71b795cab9b@[192.168.239.105]>
Message-ID: <Pine.A41.4.31.0105070003210.59664-100000@pandora.inf.elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jonathan Morton <chromi@cyberspace.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi!

On Sun, 6 May 2001, Jonathan Morton wrote:

> >-			 page_count(page) == (1 + !!page->buffers));
>
> Two inversions in a row?  I'd like to see that made more explicit,
> otherwise it looks like a bug to me.  Of course, if it IS a bug...
it's not a bug.
if page->buffers is zero, than the page_count(page) is 1, and if
page->buffers is other than zero, page_count(page) is 2.
so it checks if page is really used by something.
maybe this last line is not true, but the !!page->buffers is not a bug.

Bye,
Szabi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
