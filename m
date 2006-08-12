Message-ID: <47227.81.207.0.53.1155406611.squirrel@81.207.0.53>
In-Reply-To: <1155404014.13508.72.camel@lappy>
References: <20060812141415.30842.78695.sendpatchset@lappy>
    <33471.81.207.0.53.1155401489.squirrel@81.207.0.53>
    <1155404014.13508.72.camel@lappy>
Date: Sat, 12 Aug 2006 20:16:51 +0200 (CEST)
Subject: Re: [RFC][PATCH 0/4] VM deadlock prevention -v4
From: "Indan Zupancic" <indan@nul.nu>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, Evgeniy Polyakov <johnpol@2ka.mipt.ru>, Daniel Phillips <phillips@google.com>, Rik van Riel <riel@redhat.com>, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

On Sat, August 12, 2006 19:33, Peter Zijlstra said:
> Simpler yes, but also more complete; the old patches had serious issues
> with the alternative allocation scheme.

It sure is more complete, and looks nicer, but the price is IMHO too high.
I'm curious what those serious issues are, and if they can't be fixed.

> As for why SROG, because trying to stick all the semantics needed for
> all skb operations into the old approach was nasty, I had it almost
> complete but it was horror (and more code than the SROG approach).

What was missing or wrong in the old approach? Can't you use the new
approach, but use alloc_pages() instead of SROG?

Sorry if I bug you so, but I'm also trying to increase my knowledge here. ;-)

Greetings,

Indan


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
