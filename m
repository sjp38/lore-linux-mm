Date: Wed, 7 Jun 2000 12:15:55 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: journaling & VM  (was: Re: reiserfs being part of the kernel: it'snot just the code)
Message-ID: <20000607121555.G29432@redhat.com>
References: <Pine.LNX.4.21.0006061956360.7328-100000@duckman.distro.conectiva> <393DA31A.358AE46D@reiser.to> <yttya4ifeka.fsf@serpe.mitica> <393DC544.8D8BA7B7@reiser.to>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <393DC544.8D8BA7B7@reiser.to>; from hans@reiser.to on Tue, Jun 06, 2000 at 08:45:08PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hans Reiser <hans@reiser.to>
Cc: "Quintela Carreira Juan J." <quintela@fi.udc.es>, Rik van Riel <riel@conectiva.com.br>, "Stephen C. Tweedie" <sct@redhat.com>, bert hubert <ahu@ds9a.nl>, linux-kernel@vger.rutgers.edu, Chris Mason <mason@suse.com>, linux-mm@kvack.org, Alexander Zarochentcev <zam@odintsovo.comcor.ru>
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, Jun 06, 2000 at 08:45:08PM -0700, Hans Reiser wrote:
> > 
> > This is the reason because of what I think that one operation in the
> > address space makes no sense.  No sense because it can't be called
> > from the page.
> 
> What do you think of my argument that each of the subcaches should register
> currently_consuming counters which are the number of pages that subcache
> currently takes up in memory,

There is no need for subcaches at all if all of the pages can be
represented on the page cache LRU lists.  That would certainly make
balancing between caches easier.  However, there may be caches which
don't fit that model --- how would it work for ReiserFS if the cache 
balancing was all done through the page cache?  There is a lot of 
work being done on the VM to balance the page cache properly right  
now, and if we can use that work for journaling filesystems too, it
will make our final VM a lot less fragile over extreme load conditions.

Cheers, 
Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
