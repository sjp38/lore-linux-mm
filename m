From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14478.61468.943623.938788@dukat.scot.redhat.com>
Date: Wed, 26 Jan 2000 13:01:16 +0000 (GMT)
Subject: Re: possible brw_page optimization
In-Reply-To: <Pine.BSO.4.10.10001211508270.26216-100000@funky.monkey.org>
References: <Pine.BSO.4.10.10001211508270.26216-100000@funky.monkey.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chuck Lever <cel@monkey.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Fri, 21 Jan 2000 15:21:33 -0500 (EST), Chuck Lever <cel@monkey.org>
said:

> i've been exploring swap compaction and encryption, and found that
> brw_page wants to break pages into buffer-sized pieces in order to
> schedule I/O.  

brw_page is there explicitly to perform physical block IO to disk.  If
you want to do compression or encription, I'd have thought you want to
do that at a higher level.  The clean way to do this would be to provide
a virtual file to swap over, and to allow rw_swap_page_base() to pass
the page read or write to that file's inode's read_/write_page methods.
Then you can do any munging you want on the virtual swap file without
polluting the underlying swap IO code.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
