Subject: Re: Best way to extend try_to_free_pages()?
References: <852568E2.000A17E8.00@D51MTA03.pok.ibm.com> <20000517090839.F30758@redhat.com>
From: Trond Myklebust <trond.myklebust@fys.uio.no>
Date: 17 May 2000 11:44:12 +0200
In-Reply-To: "Stephen C. Tweedie"'s message of "Wed, 17 May 2000 09:08:39 +0100"
Message-ID: <shsog65eck3.fsf@charged.uio.no>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: frankeh@us.ibm.com, Rik van Riel <riel@conectiva.com.br>, Andreas Bombe <andreas.bombe@munich.netsurf.de>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> " " == Stephen C Tweedie <sct@redhat.com> writes:

     > Chris Mason and I have already been looking at doing something
     > similar, but on a per-page basis, to allow advanced filesystems
     > to release memory in a controlled manner.  This is particularly
     > necessary for journaled filesystems, in which releasing certain
     > data may require a transaction commit --- until the commit,
     > there is just no way shrink_mmap() will be able to free those
     > pages, so there has to be a way for shrink_mmap() to let the
     > filesystem know that it wants some memory back.

     > The route we'll probably go for this is through
     > address_space_operations callbacks from shrink_mmap.  That
     > allows proper fairness --- all fses can share the same lru that
     > way.

Could such a proposal for a per-page flushing interface perhaps also
be used for the implementation of more generic versions of 'sync()' &
friends?

Cheers,
  Trond
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
