Received: from lexa.home.net (IDENT:root@mail.datafoundation.com [10.0.0.4])
	by datafoundation.com (8.9.3/8.9.3) with SMTP id OAA20123
	for <linux-mm@kvack.org>; Sun, 6 May 2001 14:00:37 -0400
Message-Id: <200105061800.OAA20123@datafoundation.com>
Date: Sun, 6 May 2001 22:02:10 +0400
From: Alexey Zhuravlev <alexey@datafoundation.com>
Subject: about profiling and stats info for pagecache/buffercache
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello!

As far as I understand, now Linux have no facility to collect stats info
for pagecache/buffercache. For example, it'd be fine if we can see how 
many requests were submited to pagecache/buffercache and how many of 
these requests was serviced from cache without I/O. Moreover, it'd be fine
to have some profiling info on requests for pagecache/buffercache...


--
poka, lexa
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
