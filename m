Date: Wed, 28 Jun 2000 12:24:06 -0400 (EDT)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: kmap_kiobuf() 
In-Reply-To: <13214.962208390@cygnus.co.uk>
Message-ID: <Pine.LNX.3.96.1000628121852.22084D-100000@kanga.kvack.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Woodhouse <dwmw2@infradead.org>
Cc: lord@sgi.com, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 28 Jun 2000, David Woodhouse wrote:

> MM is not exactly my field - I just know I want to be able to lock down a 
> user's buffer and treat it as if it were in kernel-space, passing its 
> address to functions which expect kernel buffers.

Then pass in a kiovec (we're planning on adding a rw_kiovec file op!) and
use kmap/kmap_atomic on individual pages as required.  As to providing
larger kmaps, I have yet to be convinced that providing primatives for
dealing with objects larger than PAGE_SIZE is a Good Idea. 

		-ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
