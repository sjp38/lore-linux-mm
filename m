Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 811BB6B0206
	for <linux-mm@kvack.org>; Sun,  4 Apr 2010 15:55:52 -0400 (EDT)
Date: Sun, 4 Apr 2010 21:55:33 +0200
From: =?utf-8?B?SsO2cm4=?= Engel <joern@logfs.org>
Subject: Re: why are some low-level MM routines being exported?
Message-ID: <20100404195533.GA8836@logfs.org>
References: <alpine.LFD.2.00.1004041125350.5617@localhost> <1270396784.1814.92.camel@barrios-desktop> <20100404160328.GA30540@ioremap.net> <1270398112.1814.114.camel@barrios-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1270398112.1814.114.camel@barrios-desktop>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Evgeniy Polyakov <zbr@ioremap.net>, "Robert P. J. Day" <rpjday@crashcourse.ca>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 5 April 2010 01:21:52 +0900, Minchan Kim wrote:
> > 
> Until now, other file system don't need it. 
> Why do you need?

To avoid deadlocks.  You tell logfs to write out some locked page, logfs
determines that it needs to run garbage collection first.  Garbage
collection can read any page.  If it called find_or_create_page() for
the locked page, you have a deadlock.

I don't know how (or if) jffs2 and ubifs can avoid this particular
scenario.  The other filesystems lack garbage collection, so the problem
does not exist.

JA?rn

-- 
Joern's library part 5:
http://www.faqs.org/faqs/compression-faq/part2/section-9.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
