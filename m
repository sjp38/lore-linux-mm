Subject: Re: journaling & VM  (was: Re: reiserfs being part of the kernel: it'snot just the code)
References: <20000607144102.F30951@redhat.com>
	<Pine.LNX.4.21.0006071103560.14304-100000@duckman.distro.conectiva>
	<20000607154620.O30951@redhat.com> <yttog5decvq.fsf@serpe.mitica>
	<20000607163519.S30951@redhat.com>
From: "Juan J. Quintela" <quintela@fi.udc.es>
In-Reply-To: "Stephen C. Tweedie"'s message of "Wed, 7 Jun 2000 16:35:19 +0100"
Date: 07 Jun 2000 17:44:44 +0200
Message-ID: <yttitvlebrn.fsf@serpe.mitica>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Rik van Riel <riel@conectiva.com.br>, Hans Reiser <hans@reiser.to>, bert hubert <ahu@ds9a.nl>, linux-kernel@vger.rutgers.edu, Chris Mason <mason@suse.com>, linux-mm@kvack.org, Alexander Zarochentcev <zam@odintsovo.comcor.ru>
List-ID: <linux-mm.kvack.org>

>>>>> "stephen" == Stephen C Tweedie <sct@redhat.com> writes:

Hi

stephen> Remember that Rik is talking about multiple LRUs.  Pages can only
stephen> be on the inactive LRU if they are clean and unpinned, yes, but we
stephen> still need a way of tracking pages which are in a more difficult
stephen> state.

erhhh, If I have understand well Rik, pages in the inactive queue can
be dirty, they need to be unmmaped, but not clean.  Rik, clarify here,
please.  And yes, if you put in the Inactive queues only unpinned
page, I retire all my objections :)  But I think that all the unpinned
pages are freeable after a (possible needed write).

>> If you need pages in the LRU cache only for getting notifications,
>> then change the system to send notifications each time that we are
>> short of memory.

stephen> It's a matter of pressure.  The filesystem with most pages in the LRU
stephen> cache, or with the oldest pages there, should stand the greatest chance
stephen> of being the first one told to clean up its act.

Then if the 10 oldest pages in the LRU are from that subsystem, we
call a notifier 10 times.  That means that that subsystem will try to
free pages 10 times.  As each time it does it own clustering, etc,
etc, he has freed a *lot* of pages, when we will expect only to free
10 pages.  That means a bit unfair to me. 

Thanks a lot for your comments.

Later, Juan.

-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
