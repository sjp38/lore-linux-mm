Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id TAA21111
	for <linux-mm@kvack.org>; Sun, 27 Oct 2002 19:38:12 -0800 (PST)
Message-ID: <3DBCB123.5969FCC0@digeo.com>
Date: Sun, 27 Oct 2002 19:38:11 -0800
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: VM BUG, set_page_dirty() buggy?
References: <20021025094715.GF12628@suse.de>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jens Axboe <axboe@suse.de>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Jens Axboe wrote:
> 
> Hi,
> 
> I'm seeing what looks like a bug in set_page_dirty() in 2.5.44 (and
> 2.5.44-mm5), pages are being dumped.

It's not set_page_dirty() or direct IO.  There's a fairly long-standing
bug in the writeback code which can cause the kernel to never write out
ext2 indirect blocks.  Complete bastard of a thing it was, too.

I'll send out the fix shortly.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
