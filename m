From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14479.33307.9093.845257@dukat.scot.redhat.com>
Date: Wed, 26 Jan 2000 23:24:11 +0000 (GMT)
Subject: Re: possible brw_page optimization
In-Reply-To: <Pine.BSO.4.10.10001261054300.27169-100000@funky.monkey.org>
References: <14478.61468.943623.938788@dukat.scot.redhat.com>
	<Pine.BSO.4.10.10001261054300.27169-100000@funky.monkey.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chuck Lever <cel@monkey.org>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, 26 Jan 2000 11:02:37 -0500 (EST), Chuck Lever <cel@monkey.org>
said:

> however, somehow i'd have to guarantee that all buffers associated with a
> page that is to be compressed/encrypted are read/written at once.  

Why?  The swapper already does per-page IO locking, so you are protected
against any conflicts while a page is being written out.

>> The clean way to do this would be to provide a virtual file to swap
>> over, and to allow rw_swap_page_base() to pass the page read or write
>> to that file's inode's read_/write_page methods.  Then you can do any
>> munging you want on the virtual swap file without polluting the
>> underlying swap IO code.

> using a unique swap file/device makes it easy to tell when you need to
> decrypt a page.  :)

Sure, but the inode already gives you such an abstraction --- why invent
a new one?

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
