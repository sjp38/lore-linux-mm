Received: by fenrus.demon.nl
	via sendmail from stdin
	id <m13DObS-000OVtC@amadeus.home.nl> (Debian Smail3.2.0.102)
	for linux-mm@kvack.org; Sat, 15 Jul 2000 11:51:22 +0200 (CEST)
Message-Id: <m13DObS-000OVtC@amadeus.home.nl>
Date: Sat, 15 Jul 2000 11:51:22 +0200 (CEST)
From: arjan@fenrus.demon.nl (Arjan van de Ven)
Subject: Re: test5-pre1 VM best its EVER been!
In-Reply-To: <396F9F0A.99DFC1A2@ucla.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Redelings I <bredelin@ucla.edu>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

In article <396F9F0A.99DFC1A2@ucla.edu> you wrote:
> Hi - I've been testing test5-pre1.  I have a UP PPro 166, and 64Mb RAM.

> The last kernel that I tried was test3-p7, and it had some problems.  It
> tended to swap when there was FREE (not cache) memory still available. 
> Also, it never completely swapped out unused daemons, and tended to swap
> out large running processes, like netscape.

> test5-pre1 is wonderful.  I mean, both the stats from vmstat, free, and
> xosview, and the interactive feel.  I can REALLY run both netscape and
> quake and the same time!  The system rarely hits the disk - which is a
> welcome change.  Things the you might hope to be in the cache,
> apparently are...

I am much less happy. My 128Mb system will not stop freeing memory (from the
buffer/page caches) until at least 16 Mb is really free. This means I
typically end up with 400kb buffer and 20M cached, which could be much
higher..... 

The swap behaviour seems OK though... only 8Mb in swap.

Greetings,
   Arjan van de Ven
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
