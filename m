Received: from typhon.torrent.com by chi6sosrv11.alter.net with SMTP
	(peer crosschecked as: typhon.torrent.com [208.223.133.146])
	id QQhaou21148
	for <linux-mm@kvack.org>; Mon, 2 Aug 1999 22:00:12 GMT
From: dca@torrent.com
Date: Mon, 2 Aug 1999 17:59:18 -0400
Message-Id: <199908022159.RAA03948@grappelli.torrent.com>
Subject: getrusage
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The implementation of getrusage(2) appears incomplete in the stock
2.2.10 kernel; it's missing memory statistics e.g. the rss numbers.
(It's also missing I/O statistics, but I assume you don't want to hear
about them.)

Is this an old design decision, or simply an oversight?  If an
oversight, I'd be happy to propose a patch for it.

Dave Anderson
dca@torrent.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
