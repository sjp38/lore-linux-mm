Subject: Re: [PATCH,incomplete] shm integration into shrink_mmap
References: <Pine.LNX.4.21.0006071025330.14304-100000@duckman.distro.conectiva>
	<qww7lc1pnt0.fsf@sap.com> <20000607154350.N30951@redhat.com>
	<qwwg0qob4ef.fsf_-_@sap.com>
From: "Juan J. Quintela" <quintela@fi.udc.es>
In-Reply-To: Christoph Rohland's message of "08 Jun 2000 17:04:24 +0200"
Date: 08 Jun 2000 17:21:30 +0200
Message-ID: <yttpupsb3lx.fsf@serpe.mitica>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Rohland <cr@sap.com>
Cc: Rik van Riel <riel@conectiva.com.br>, "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "christoph" == Christoph Rohland <cr@sap.com> writes:

Hi christoph

christoph> Here is my first proposal for changing shm to be integrated into
christoph> shrink_mmap.

christoph> It gives you a function 'int shm_write_swap (struct page *page)' to
christoph> write out a page to swap and replace the pte in the shm structures.  I
christoph> tested the stuff with no swapping and it seems stable so far. But
christoph> shm_write_swap is completely untested.

christoph> It probably needs to add the pages in shm_nopage_core to your lru
christoph> queues and of course it needs the calls from shrink_mmap.

christoph> I think it would be nicer to only have a notify function instead of
christoph> shm_write_swap, which gets the page and the swap_entry and can simply
christoph> put the swap_entry into the shm structures without handling the
christoph> swapping at all.

christoph> What do you think?
christoph>         		Christoph

It lacks the cleanup of the SHM page bit :)))
But it looks great so far.  I am working just now it the shrink_mmap
integration.

Later, Juan.

-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
