Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id A3C7038D0B
	for <linux-mm@kvack.org>; Thu, 25 Jul 2002 13:44:11 -0300 (EST)
Date: Thu, 25 Jul 2002 13:44:10 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [RFC] start_aggressive_readahead
In-Reply-To: <20020725181059.A25857@lst.de>
Message-ID: <Pine.LNX.4.44L.0207251343180.8815-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: torvalds@transmeta.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 25 Jul 2002, Christoph Hellwig wrote:

> This function (start_aggressive_readahead()) checks whether all zones
> of the given gfp mask have lots of free pages.

Seems a bit silly since ideally we wouldn't reclaim cache memory
until we're low on physical memory.


regards,

Rik
-- 
	http://www.linuxsymposium.org/2002/
"You're one of those condescending OLS attendants"
"Here's a nickle kid.  Go buy yourself a real t-shirt"

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
