Date: Wed, 7 Jun 2000 14:47:43 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: journaling & VM  (was: Re: reiserfs being part of the kernel: it'snot just the code)
Message-ID: <20000607144743.H30951@redhat.com>
References: <20000607121555.G29432@redhat.com> <Pine.LNX.4.10.10006070629590.9710-100000@home.suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.10.10006070629590.9710-100000@home.suse.com>; from mason@suse.com on Wed, Jun 07, 2000 at 06:40:24AM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Mason <mason@suse.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Hans Reiser <hans@reiser.to>, "Quintela Carreira Juan J." <quintela@fi.udc.es>, Rik van Riel <riel@conectiva.com.br>, bert hubert <ahu@ds9a.nl>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Alexander Zarochentcev <zam@odintsovo.comcor.ru>
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Jun 07, 2000 at 06:40:24AM -0700, Chris Mason wrote:
> 
> Right now, almost of the pinned pages will be buffer cache pages, and only
> metadata is logged.  But, sometimes a data block must be flushed before
> transaction commit, and those pages are pinned, but can be written at any
> time.  I'm not sure I fully understand the issues with doing all the
> balancing through the page cache...

In 2.4, it's not a problem in principle to keep the buffer cache pages
on the page cache LRUs, even if they are not on the page cache hash 
lists.

> Allocate on flush will be different, and the address_space->pressure()
> method makes even more sense there.  Those pages will be on the LRU lists,
> and you want the pressure function to be called on each page.

Absolutely.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
