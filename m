Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id OAA14774
	for <linux-mm@kvack.org>; Mon, 9 Sep 2002 14:53:02 -0700 (PDT)
Message-ID: <3D7D182D.3514E0AD@digeo.com>
Date: Mon, 09 Sep 2002 14:52:45 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: [PATCH] modified segq for 2.5
References: <3D7D09D7.2AE5AD71@digeo.com> <Pine.LNX.4.44L.0209091808160.1857-100000@imladris.surriel.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: William Lee Irwin III <wli@holomorphy.com>, sfkaplan@cs.amherst.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> 
> On Mon, 9 Sep 2002, Andrew Morton wrote:
> > Rik van Riel wrote:
> 
> > > Move them to the inactive list the moment we're done writing
> > > them, that is, the moment we move on to the next page. We
> >
> > The moment "who" has done writing them?  Some writeout
> > comes in via shrink_foo() and a ton of writeout comes in
> > via balance_dirty_pages(), pdflush, etc.
> 
> generic_file_write, once that function moves beyond the last
> byte of the page, onto the next page, we can be pretty sure
> it's done writing to this page

Oh.  So why don't we just start those new pages out on the
inactive list?

I fear that this change will result in us encountering more dirty
pages on the inactive list.  It could be that moving then onto the
inactive list when IO is started is a good compromise - that will
happen pretty darn quick if the system is under dirty pressure
anyway.

Do we remove the SetPageReferenced() in generic_file_write?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
