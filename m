Date: Thu, 29 Jun 2000 14:45:57 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: 2.4 / 2.5 VM plans
Message-ID: <20000629144557.S3473@redhat.com>
References: <Pine.LNX.4.21.0006242357020.15823-100000@duckman.distro.conectiva> <yttitutwlmi.fsf@serpe.mitica>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <yttitutwlmi.fsf@serpe.mitica>; from quintela@fi.udc.es on Wed, Jun 28, 2000 at 11:17:57PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Juan J. Quintela" <quintela@fi.udc.es>
Cc: Rik van Riel <riel@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Jun 28, 2000 at 11:17:57PM +0200, Juan J. Quintela wrote:

> 2.5:
> 
> 7) Make a ->flush method in the address_space operations

OK

> 8) This one is related with the FS, not MM specific, but FS people
>    want to be able to allocate MultiPage buffers (see pagebuf from
>    XFS) and people want similar functionality for other things.

Yes, but this should be layered on top of the page handling ---
there's no need to integrate it into the low levels of the page cache.

> 9) We need also to implement write clustering for fs/page cache/swap.

Same as above.  When the pagebuf layer or whatever gets a write
request for a given page, it is perfectly at liberty to write out
adjacent pages too if it wants to.  The VM doesn't have to enforce
that itself.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
