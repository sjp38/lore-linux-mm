Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id WAA01343
	for <linux-mm@kvack.org>; Mon, 14 Oct 2002 22:20:24 -0700 (PDT)
Message-ID: <3DABA596.39C9D782@digeo.com>
Date: Mon, 14 Oct 2002 22:20:22 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: 2.5.43-m3
References: <3DABA351.7E9C1CFB@digeo.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, ext2-devel@lists.sourceforge.net, "tytso@mit.edu" <tytso@mit.edu>
List-ID: <linux-mm.kvack.org>

yeah, yeah.  off-by-one.

Andrew Morton wrote:
> 
> ...
> - Add Ingo's current remap_file_pages() patch.  I had to renumber his
>   syscall from 253 to 254 due to a clash with the oprofile syscall.
> 

This will only work on ia32.  To test on other architectures, please
do a patch -p1 -R of

http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.42/2.5.42-mm3/broken-out/mpopulate.patch
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
