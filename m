Date: Thu, 7 Jun 2001 13:59:26 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: VM tuning patch, take 2
In-Reply-To: <l03130318b74568171b40@[192.168.239.105]>
Message-ID: <Pine.LNX.4.21.0106071357460.1156-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jonathan Morton <chromi@cyberspace.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Thu, 7 Jun 2001, Jonathan Morton wrote:

> - new pages are still given an age of PAGE_AGE_START, which is 2.
> PAGE_AGE_ADV has been increased to 4, and PAGE_AGE_MAX to 128.  Pages which
> are demand-paged in from swap are given an initial age of PAGE_AGE_MAX/2,
> or 64 - this should help to keep these (expensive) pages around for as long
> as possible.  Ageing down is now done using a decrement instead of a
> division by 2, preserving the age information for longer.

Just one comment about this specific change. I would not like to tweak the
PAGE_AGE_* values until we have centralized page aging. (ie only kswapd
doing the aging) 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
