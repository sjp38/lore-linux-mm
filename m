Message-ID: <3B1E2C3C.55DF1E3C@uow.edu.au>
Date: Wed, 06 Jun 2001 23:12:28 +1000
From: Andrew Morton <andrewm@uow.edu.au>
MIME-Version: 1.0
Subject: Re: [PATCH] reapswap for 2.4.5-ac10
References: <3B1E203C.5DC20103@uow.edu.au>,
		<l03130308b7439bb9f187@[192.168.239.105]> <l0313030db743d4a05018@[192.168.239.105]>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jonathan Morton <chromi@cyberspace.org>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Jonathan Morton wrote:
> 
> >So the more users, the more slowly it ages.  You get the idea.
> 
> However big you make that scaling constant, you'll always find some pages
> which have more users than that.

2^24?

> BUT, as it turns out, refill_inactive_scan() already does ageing down on a
> page-by-page basis, rather than process-by-process.

Yes.  page->count needs looking at if you're doing physically-addressed
scanning.  Rik's patch probably does that.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
