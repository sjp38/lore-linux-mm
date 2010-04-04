Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 741C06B01F7
	for <linux-mm@kvack.org>; Sun,  4 Apr 2010 11:29:47 -0400 (EDT)
Received: from guests.acceleratorcentre.net ([209.222.173.41] helo=crashcourse.ca)
	by astoria.ccjclearline.com with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.69)
	(envelope-from <rpjday@crashcourse.ca>)
	id 1NyRlg-0005Xq-SF
	for linux-mm@kvack.org; Sun, 04 Apr 2010 11:29:44 -0400
Date: Sun, 4 Apr 2010 11:27:34 -0400 (EDT)
From: "Robert P. J. Day" <rpjday@crashcourse.ca>
Subject: why are some low-level MM routines being exported?
Message-ID: <alpine.LFD.2.00.1004041125350.5617@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


  perusing the code in mm/filemap.c and i'm curious as to why routines
like, for example, add_to_page_cache_lru() are being exported.  is it
really expected that loadable modules might access routines like that
directly?

rday
--

========================================================================
Robert P. J. Day                               Waterloo, Ontario, CANADA

            Linux Consulting, Training and Kernel Pedantry.

Web page:                                          http://crashcourse.ca
Twitter:                                       http://twitter.com/rpjday
========================================================================

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
