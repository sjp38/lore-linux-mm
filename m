Date: Tue, 27 Jun 2006 20:23:25 +0200
From: stanojr@blackhole.websupport.sk
Subject: slow hugetlb from 2.6.15
Message-ID: <20060627182325.GE6380@blackhole.websupport.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

hello

look at this benchmark http://www-unix.mcs.anl.gov/~kazutomo/hugepage/note.html
i try benchmark it on latest 2.6.17.1 (x86 and x86_64) and it slow like 2.6.16 on that web
(in comparing to standard 4kb page)
its feature or bug ? 
i am just interested where can be hugepages used, but if they are slower than normal pages
its pointless to use it :) 

stanojr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
