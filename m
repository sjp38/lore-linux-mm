Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id XAA19142
	for <linux-mm@kvack.org>; Sat, 21 Sep 2002 23:11:55 -0700 (PDT)
Message-ID: <3D8D5F2A.BC057FC4@digeo.com>
Date: Sat, 21 Sep 2002 23:11:54 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: 2.5.38-mm1
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Well that didn't last very long.

url: http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.38/2.5.38-mm1/

+filemap-fixes.patch

 Fix mm/filemap.c for 64-bit builds: replace `unsigned' with size_t.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
