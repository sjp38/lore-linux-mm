Date: Wed, 7 Jun 2000 15:01:22 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: journaling & VM  (was: Re: reiserfs being part of the kernel:
 it'snot just the code)
In-Reply-To: <393E8AEF.7A782FE4@reiser.to>
Message-ID: <Pine.LNX.4.21.0006071459040.14304-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hans Reiser <hans@reiser.to>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, bert hubert <ahu@ds9a.nl>, linux-kernel@vger.rutgers.edu, Chris Mason <mason@suse.com>, linux-mm@kvack.org, Alexander Zarochentcev <zam@odintsovo.comcor.ru>
List-ID: <linux-mm.kvack.org>

On Wed, 7 Jun 2000, Hans Reiser wrote:
> "Stephen C. Tweedie" wrote:
> 
> > Use reservations.  That's the point --- you reserve in advance, so that
> > the VM can *guarantee* that you can continue to pin more pages up to
> > the maximum you have reserved.  You take a reservation before starting
> > a fs operation, so that if you need to block, it doesn't prevent the
> > running transaction from being committed.
> 
> Ok, let's admit it, we have been agreeing on this with you for 9
> months and no code has been written by any of us.:-/

I'd like to be able to keep stuff simple in the shrink_mmap
"equivalent" I'm working on. Something like:

if (PageDirty(page) && page->mapping && page->mapping->flush)
	maxlaunder -= page->mapping->flush();

Where the flush() function would return the amount of _inactive_
pages that were flushed at the time we called this function...
(we should not decrease maxlaunder if we flushed active pages
since that would imply we didn't make any progress)

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
