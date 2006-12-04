Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate1.uk.ibm.com (8.13.8/8.13.8) with ESMTP id kB4DVY8U080416
	for <linux-mm@kvack.org>; Mon, 4 Dec 2006 13:31:35 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kB4DVYG72646110
	for <linux-mm@kvack.org>; Mon, 4 Dec 2006 13:31:34 GMT
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kB4DVWkJ012108
	for <linux-mm@kvack.org>; Mon, 4 Dec 2006 13:31:33 GMT
Date: Mon, 4 Dec 2006 14:31:32 +0100
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: [PATCH/RFC 0/5] vmemmap for s390 take 2
Message-ID: <20061204133132.GB9209@osiris.boeblingen.de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Carsten Otte <cotte@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

This is an s390 implementation (both 31 and 64 bit) of virtual memmap.
ia64 was used as a blueprint of course. I hope I incorporated everything
I read lately on linux-mm wrt. vmemmap.
So I post this as an RFC, since I most probably have forgotten something,
or did something wrong. Comments highly appreciated.

This patchset is against linux-2.6.19-rc6-mm2.

Patch 1 is sort of unrelated to the vmemmap patch but still needed, so
that the patch applies.
Patch 2 is the vmemmap implementation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
