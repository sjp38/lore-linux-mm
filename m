Date: Wed, 17 May 2000 11:48:46 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: Best way to extend try_to_free_pages()?
Message-ID: <20000517114846.P30758@redhat.com>
References: <852568E2.000A17E8.00@D51MTA03.pok.ibm.com> <20000517090839.F30758@redhat.com> <shsog65eck3.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <shsog65eck3.fsf@charged.uio.no>; from trond.myklebust@fys.uio.no on Wed, May 17, 2000 at 11:44:12AM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, frankeh@us.ibm.com, Rik van Riel <riel@conectiva.com.br>, Andreas Bombe <andreas.bombe@munich.netsurf.de>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, May 17, 2000 at 11:44:12AM +0200, Trond Myklebust wrote:
> 
>      > The route we'll probably go for this is through
>      > address_space_operations callbacks from shrink_mmap.  That
>      > allows proper fairness --- all fses can share the same lru that
>      > way.
> 
> Could such a proposal for a per-page flushing interface perhaps also
> be used for the implementation of more generic versions of 'sync()' &
> friends?

Right now, the write_super() callback to the fs is about the best
place to trap syncs.  I'm not sure that you want to have per-page 
callbacks for sync --- you really want the fs to be able to batch
things up itself.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
