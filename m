From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14480.41441.263356.926202@dukat.scot.redhat.com>
Date: Thu, 27 Jan 2000 19:52:01 +0000 (GMT)
Subject: Re: possible brw_page optimization
In-Reply-To: <Pine.BSO.4.10.10001271342110.20668-100000@funky.monkey.org>
References: <14479.33307.9093.845257@dukat.scot.redhat.com>
	<Pine.BSO.4.10.10001271342110.20668-100000@funky.monkey.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chuck Lever <cel@monkey.org>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, 27 Jan 2000 13:50:23 -0500 (EST), Chuck Lever <cel@monkey.org>
said:

> forgetting about encryption for a moment, you don't think the optimization
> is useful in the general case?  it's hardly ever used, if at all; plus it
> seems to introduce some bugs.  that code would be a lot cleaner without
> all the bother.  the "common case," by far, is to read/write the whole
> page.

Fine, if you can clean up the rw-page code, show us patches, certainly.
It's just not the place to be doing encryption: that's a separate
layering issue.  Doing it via a dedicated swap inode would be far
better. 

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
