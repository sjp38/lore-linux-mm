Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id NAA12332
	for <linux-mm@kvack.org>; Mon, 9 Sep 2002 13:51:54 -0700 (PDT)
Message-ID: <3D7D09D7.2AE5AD71@digeo.com>
Date: Mon, 09 Sep 2002 13:51:35 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: [PATCH] modified segq for 2.5
References: <3D7CF077.FB251EC7@digeo.com> <Pine.LNX.4.44L.0209091622470.1857-100000@imladris.surriel.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: William Lee Irwin III <wli@holomorphy.com>, sfkaplan@cs.amherst.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> 
> ...
> > > Hmmm indeed, I forgot this.  Note that IO completion state is
> > > too late, since then you'll have already pushed other pages
> > > out to the inactive list...
> >
> > OK.  So how would you like to handle those pages?
> 
> Move them to the inactive list the moment we're done writing
> them, that is, the moment we move on to the next page. We
> wouldn't want to move the last page from /var/log/messages to
> the inactive list all the time ;)

The moment "who" has done writing them?  Some writeout
comes in via shrink_foo() and a ton of writeout comes in
via balance_dirty_pages(), pdflush, etc.

Do we need to distinguish between the various contexts?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
