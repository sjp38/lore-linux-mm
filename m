Message-ID: <393ECB3C.91299E78@colorfullife.com>
Date: Thu, 08 Jun 2000 00:22:52 +0200
From: Manfred Spraul <manfreds@colorfullife.com>
MIME-Version: 1.0
Subject: Re: journaling & VM  (was: Re: reiserfs being part of the kernel:
 it'snot just the code)
References: <393E8AEF.7A782FE4@reiser.to> <Pine.LNX.4.21.0006071459040.14304-100000@duckman.distro.conectiva> <20000607205819.E30951@redhat.com> <ytt1z29dxce.fsf@serpe.mitica> <20000607222421.H30951@redhat.com> <yttvgzlcgps.fsf@serpe.mitica> <20000607224908.K30951@redhat.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: "Juan J. Quintela" <quintela@fi.udc.es>, Rik van Riel <riel@conectiva.com.br>, Hans Reiser <hans@reiser.to>, bert hubert <ahu@ds9a.nl>, linux-kernel@vger.rutgers.edu, Chris Mason <mason@suse.com>, linux-mm@kvack.org, Alexander Zarochentcev <zam@odintsovo.comcor.ru>
List-ID: <linux-mm.kvack.org>

"Stephen C. Tweedie" wrote:
> 
> Hi,
> 
> On Wed, Jun 07, 2000 at 11:40:47PM +0200, Juan J. Quintela wrote:
> > Hi
> > Fair enough, don't put pinned pages in the LRU, *why* do you want put
> > pages in the LRU if you can't freed it when the LRU told it: free that
> > page?
> 
> Because even if the information about which page is least recently
> used doesn't help you, the information about which filesystems are
> least active _does_ help.
> 

What about using a time based aproach for pinned pages?

* only individually freeable pages are added into the LRU.
* everyone else registers callbacks.
* shrink_mmap estimates (*) the age (in jiffies) of the oldest entry in
the LRU, and then it calls the pressure callbacks with that time.

(*) nr_of_lru_pages/lru_reclaimed_pages_during_last_jiffies. Another
field in "struct page" is too expensive.

--
	Manfred
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
