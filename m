Subject: Re: Comment on patch to remove nr_async_pages limit
References: <Pine.LNX.4.33.0106051140270.1227-100000@mikeg.weiden.de>
	<01060507422800.28232@oscar>
Reply-To: zlatko.calusic@iskon.hr
From: Zlatko Calusic <zlatko.calusic@iskon.hr>
Date: 05 Jun 2001 18:08:45 +0200
In-Reply-To: <01060507422800.28232@oscar> (Ed Tomlinson's message of "Tue, 5 Jun 2001 07:42:28 -0400")
Message-ID: <87u21uykmq.fsf@atlas.iskon.hr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Tomlinson <tomlins@cam.org>
Cc: Mike Galbraith <mikeg@wen-online.de>, Marcelo Tosatti <marcelo@conectiva.com.br>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ed Tomlinson <tomlins@cam.org> writes:

[snip]
> Maybe we can have the best of both worlds.  Is it possible to allocate the BH
> early and then defer the IO?  The idea being to make IO possible without having
> to allocate.  This would let us remove the async page limit but would ensure
> we could still free.
> 

Yes, this is a good idea if you ask me. Basically, to remove as many
limits as we can, and also to secure us from the deadlocks. With just
a few pages of extra memory for the reserved buffer heads, I think
it's a fair game. Still, pending further analysis...
-- 
Zlatko
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
