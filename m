Received: from Tandem.com (suntan.tandem.com [192.216.221.8])
	by kvack.org (8.8.7/8.8.7) with ESMTP id IAA11142
	for <linux-mm@kvack.org>; Sun, 22 Mar 1998 08:26:37 -0500
Date: Sun, 22 Mar 1998 18:57:28 +0530 (GMT+0530)
From: Chirayu Patel <chirayu@wipro.tcpn.com>
Subject: __free_page() and free_pages() - Differences?
Message-Id: <Pine.SUN.3.95.980322184553.3977Z-100000@Kabini>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Hi ,

I am having trouble understanding the difference between 
the __free_page function and free_pages function in page_alloc.c

The only difference which I can see is that free_pages decrement map->count
while __free_page decrements the page->count. Both of them eventually make
a call to free_pages_ok with identical parametrs. 

Can anyone shed some light on this?

yet-another-mm-hacker,
Chirayu
