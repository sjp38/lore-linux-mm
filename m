Received: from computer (dc-lata-1-43.dynamic-dialup.coretel.net [162.33.62.43])
	by boo-mda02.boo.net (8.9.3/8.9.3) with SMTP id BAA06785
	for <linux-mm@kvack.org>; Tue, 15 Jan 2002 01:10:17 -0500
Message-Id: <3.0.6.32.20020115011634.007b86a0@boo.net>
Date: Tue, 15 Jan 2002 01:16:34 -0500
From: Jason Papadopoulos <jasonp@boo.net>
Subject: Re: [PATCH] page coloring for 2.4.17 kernel
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I know it's bad form to respond to my own post, but I've done some
more careful lmbench runs and many of the glaring differences in the
2.4.17 kernel with and without page coloring seem to damp out. The
AF UNIX and File reread bandwidths are consistently better across multiple
runs, though. 

Sorry about that,
jasonp
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
