Date: Thu, 27 Jan 2000 13:50:23 -0500 (EST)
From: Chuck Lever <cel@monkey.org>
Subject: Re: possible brw_page optimization
In-Reply-To: <14479.33307.9093.845257@dukat.scot.redhat.com>
Message-ID: <Pine.BSO.4.10.10001271342110.20668-100000@funky.monkey.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 26 Jan 2000, Stephen C. Tweedie wrote:
> On Wed, 26 Jan 2000 11:02:37 -0500 (EST), Chuck Lever <cel@monkey.org>
> said:
> > however, somehow i'd have to guarantee that all buffers associated with a
> > page that is to be compressed/encrypted are read/written at once.  
> 
> Why?  The swapper already does per-page IO locking, so you are protected
> against any conflicts while a page is being written out.

it's not a locking issue. the encryption algorithm is a block cipher on
the whole page. in order to decrypt a page, you need to be sure you have
all the pieces.  you can't read parts of the page and decrypt them.

forgetting about encryption for a moment, you don't think the optimization
is useful in the general case?  it's hardly ever used, if at all; plus it
seems to introduce some bugs.  that code would be a lot cleaner without
all the bother.  the "common case," by far, is to read/write the whole
page.

	- Chuck Lever
--
corporate:	<chuckl@netscape.com>
personal:	<chucklever@netscape.net> or <cel@monkey.org>

The Linux Scalability project:
	http://www.citi.umich.edu/projects/linux-scalability/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
