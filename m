Received: from bigalpha.imi.com (bigalpha.imi.com [199.125.186.10])
	by kvack.org (8.8.7/8.8.7) with SMTP id VAA22992
	for <linux-mm@kvack.org>; Mon, 15 Feb 1999 21:28:29 -0500
Message-Id: <9902160001.AA15015@bigalpha.imi.com>
Date: Mon, 15 Feb 1999 21:30:22 -0500
Subject: MM question
From: "Jason Titus" <jason@iatlas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I know this must be on a FAQ or some such, but after many hours of 
newsgroup/web searching - nothing.

Is there a way to turn off/down the page caching and buffering?  I'm doing
database work and am having a really time benchmarking other elements of the
system due to Linux's friendly caching....

I have tried editing /proc/sys/vm/pagecache and buffermem, but the changes
don't seem to do anything (2.2.0-pre5 - x86).  Is there something you have
to do to activate the changes?  Is there some other file to edit to set the
variables at boot time?

It sure would be nice to have more control over the caching, like being able
to have a /etc/cache.conf file where you could set parameters and mark
certain files/filetypes as priority cache items...

Anyway, any help would be much appreciated, and sorry for the ignorant
question,

Jason Titus
jason@iatlas.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
