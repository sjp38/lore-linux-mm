Received: from smtp02.mail.gol.com (smtp02.mail.gol.com [203.216.5.12])
	by kvack.org (8.8.7/8.8.7) with ESMTP id VAA21533
	for <linux-mm@kvack.org>; Fri, 26 Feb 1999 21:37:58 -0500
Message-ID: <36D75AF7.18C593E7@earthling.net>
Date: Sat, 27 Feb 1999 11:39:51 +0900
From: Neil Booth <NeilB@earthling.net>
MIME-Version: 1.0
Subject: Re: PATCH - bug in vfree
References: <36CEA095.D5EA37B5@earthling.net> <36CEA72C.7B86B221@earthling.net>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Andrea Arcangeli <andrea@e-mind.com>
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli wrote:

> Hmm, when I checked it one year ago I didn't seen a way the bug could
> corrupt memory.

Yes, you missed my retraction of that bit below.

Neil.

Neil Booth wrote:
> 
> Neil Booth wrote:
> 
> > More deeply:- Close inspection of get_vm_area reveals that
> > (intentionally?) it does NOT insist there be a cushion page behind a VMA
> > that is placed in front of a previously-allocated VMA, it ONLY
> > guarantees that a cushion page lies in front of newly-allocated VMAs.
> 
> Sorry, this is not correct (mistook < for <=). The bug report is
> correct, though.
> 
> Neil.
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
