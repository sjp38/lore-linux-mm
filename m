Received: from prefetch-atm.san.rr.com (root@ns1.san.rr.com [204.210.0.2])
	by kvack.org (8.8.7/8.8.7) with ESMTP id BAA09801
	for <linux-mm@kvack.org>; Sat, 9 Jan 1999 01:40:50 -0500
Message-ID: <369709CF.E38FEE6F@ucsd.edu>
Date: Fri, 08 Jan 1999 23:48:31 -0800
From: Benjamin Redelings I <bredelin@ucsd.edu>
MIME-Version: 1.0
Subject: Re: 2.2.0-pre[56] swap performance poor with > 1 thrashing task
References: <Pine.LNX.4.04.9901082246490.1183-100000@brookie.inconnect.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dax Kelson <dkelson@inconnect.com>
Cc: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Linus Torvalds <torvalds@transmeta.com>, Steve Bergman <steve@netplus.net>, Andrea Arcangeli <andrea@e-mind.com>, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Ben McCann <bmccann@indusriver.com>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

	Maybe this is not really a problem with swapping, but more with
concurrent I/O in general, because I KNOW that running low-priority
niced jobs in the background (e.g. updatedb) can seriously degrade
performance of tasks in the foreground (e.g. netscape) that are doing a
minimal amount of I/O.  I think I've seen a few people mention this in
the past also.
	In any case, I've kind of assumed that that was the way it is supposed
to be.  Perhaps it is just that IDE drives really don't like writing 2
files at once.  Or that the background task does a lot of I/O, and the
clustering algorithm makes sure it all gets written before anything else
happens.  Anyway, I bet those explanations are wrong, but maybe there is
another explanation.... I don't know.
	Ah.  So Zlatko has a patch.  I look forward to it, and hope it improves
performance of non-swapping applications also.

-benRI
-- 
I don't need     education.
I don't need ANY education.
I don't need NO  education.

Benjamin Redelings I       <><      http://sdcc13.ucsd.edu/~bredelin
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
