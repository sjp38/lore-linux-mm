Received: from popmail.esa.lanl.gov (localhost.localdomain [127.0.0.1])
	by mailrelay2.lanl.gov (8.12.3/8.12.3/(ccn-5)) with ESMTP id g7FHYLMl017600
	for <linux-mm@kvack.org>; Thu, 15 Aug 2002 11:34:54 -0600
Received: from spc9.esa.lanl.gov (128.165.67.199) by popmail.esa.lanl.gov (Worldmail 1.3.167) for linux-mm@kvack.org; 15 Aug 2002 11:34:54 -0600
Subject: kernel BUG at page_alloc.c:185! with 2.5.31 + akpm stuff
From: Steven Cole <elenstev@mesatop.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 15 Aug 2002 11:31:54 -0600
Message-Id: <1029432714.2051.232.camel@spc9.esa.lanl.gov>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

With this patch applied to 2.5.31,

http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.31/stuff-sent-to-linus/everything.gz

I got these BUGs,

kernel BUG at page_alloc.c:185!
 kernel BUG at page_alloc.c:98!

I was running dbench as a stress tester.  I had run dbench with
up to 128 clients with no problems, and was running my stress test a
second time when the BUGs occurred with dbench 6.

I have run the dbench 1..128 stress test with plain vanilla 2.5.31 four
times without these failures.

This is on a 2-way p-III box, CONFIG_SMP=y.

Steven


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
