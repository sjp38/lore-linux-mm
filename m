Received: from relay-1.seagha.com (relay-1.seagha.com [193.75.252.18])
	by kvack.org (8.8.7/8.8.7) with ESMTP id GAA10258
	for <linux-mm@kvack.org>; Tue, 18 May 1999 06:18:46 -0400
Received: from alpha.antwerp.seagha.com ([10.200.1.6])
	by relay-1.seagha.com with smtp
	id 10jgx2-0001ga-00
	for linux-mm@kvack.org; Tue, 18 May 1999 12:18:20 +0200
Message-Id: <001501bea117$c0a2d850$2b01c80a@pc-kvo.antwerp.seagha.com>
From: "Karl Vogel" <kvo@mail.seagha.com>
Subject: Swapping out old pages
Date: Tue, 18 May 1999 12:18:19 +0200
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I recently became interested in all this VM stuff, so I'm not what you would
call an expert (more like a newbie), but when browsing through the 2.2 mm
sources, the following questions popped into my mind:

- why does the swap out algorithm select the task with the largest RSS to
free pages. If I'm not mistaken, the age of a page isn't considered?! Why is
that? Am I overlooking something? (doesn't this mean that if I start a new
large process, it's pages immediately get swapped out even though there are
other processes that haven't done anything in the past couple of hours)

- wouldn't it be beneficial if there is a parameter that allows you to
specify that after a certain age, a page is swapped out to make room for the
buffer cache. (even if the system has plenty of ram left - the idea is that:
if your system has alot of RAM, old/unused pages (e.g. init code from
daemons etc) are never swapped out and take away ram that can be used for
better things).




--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
