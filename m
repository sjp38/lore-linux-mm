Content-Type: text/plain;
  charset="iso-8859-1"
From: Ed Tomlinson <tomlins@cam.org>
Subject: Re: Comment on patch to remove nr_async_pages limit
Date: Tue, 5 Jun 2001 07:42:28 -0400
References: <Pine.LNX.4.33.0106051140270.1227-100000@mikeg.weiden.de>
In-Reply-To: <Pine.LNX.4.33.0106051140270.1227-100000@mikeg.weiden.de>
MIME-Version: 1.0
Message-Id: <01060507422800.28232@oscar>
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Galbraith <mikeg@wen-online.de>, Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: Zlatko Calusic <zlatko.calusic@iskon.hr>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

To paraphase Mike,

We defer doing IO until we are under short of storage.  Doing IO uses storage.
So delaying IO as much as we do forces us to impose limits.  If we did the IO
earlier we would not need this limit often, if at all.

Does this make any sense?

Maybe we can have the best of both worlds.  Is it possible to allocate the BH
early and then defer the IO?  The idea being to make IO possible without having
to allocate.  This would let us remove the async page limit but would ensure
we could still free.

Thoughts?
Ed Tomlinson
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
