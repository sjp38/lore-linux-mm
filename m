Received: from smtp01.mail.gol.com (smtp01.mail.gol.com [203.216.5.11])
	by kvack.org (8.8.7/8.8.7) with ESMTP id HAA08705
	for <linux-mm@kvack.org>; Sat, 20 Feb 1999 07:12:38 -0500
Message-ID: <36CEA72C.7B86B221@earthling.net>
Date: Sat, 20 Feb 1999 21:14:36 +0900
From: Neil Booth <NeilB@earthling.net>
MIME-Version: 1.0
Subject: Re: PATCH - bug in vfree
References: <36CEA095.D5EA37B5@earthling.net>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Neil Booth wrote:

> More deeply:- Close inspection of get_vm_area reveals that
> (intentionally?) it does NOT insist there be a cushion page behind a VMA
> that is placed in front of a previously-allocated VMA, it ONLY
> guarantees that a cushion page lies in front of newly-allocated VMAs.

Sorry, this is not correct (mistook < for <=). The bug report is
correct, though.

Neil.
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
