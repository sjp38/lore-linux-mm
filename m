Date: Wed, 7 Jun 2000 22:24:21 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: journaling & VM  (was: Re: reiserfs being part of the kernel: it'snot just the code)
Message-ID: <20000607222421.H30951@redhat.com>
References: <393E8AEF.7A782FE4@reiser.to> <Pine.LNX.4.21.0006071459040.14304-100000@duckman.distro.conectiva> <20000607205819.E30951@redhat.com> <ytt1z29dxce.fsf@serpe.mitica>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ytt1z29dxce.fsf@serpe.mitica>; from quintela@fi.udc.es on Wed, Jun 07, 2000 at 10:56:17PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Juan J. Quintela" <quintela@fi.udc.es>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Rik van Riel <riel@conectiva.com.br>, Hans Reiser <hans@reiser.to>, bert hubert <ahu@ds9a.nl>, linux-kernel@vger.rutgers.edu, Chris Mason <mason@suse.com>, linux-mm@kvack.org, Alexander Zarochentcev <zam@odintsovo.comcor.ru>
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Jun 07, 2000 at 10:56:17PM +0200, Juan J. Quintela wrote:
> 
> >> I'd like to be able to keep stuff simple in the shrink_mmap
> >> "equivalent" I'm working on. Something like:
> >> 
> >> if (PageDirty(page) && page->mapping && page->mapping->flush)
> >> maxlaunder -= page->mapping->flush();
> 
> sct> That looks ideal.
> 
> But this is supposed to flush that _page_, at least in the normal
> case.

All transactional filesystems will have ordering constraints which
the core VM cannot know about.  In that case, the filesystem may
simply have no choice about cleaning and unpinning pages in a given
order.  For actually removing a page from memory, evicting precisely
the right page is far more important, but for writeback, it's
controlling the amount of dirty/pinned data from the various different
sources which counts.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
